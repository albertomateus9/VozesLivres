import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sound_stream/sound_stream.dart';
import 'package:dialogflow_grpc/dialogflow_grpc.dart';
import 'package:dialogflow_grpc/generated/google/cloud/dialogflow/v2beta1/session.pb.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isRecording = false;

  final RecorderStream _recorder = RecorderStream();
  StreamSubscription? _recorderStatus;
  StreamSubscription<List<int>>? _audioStreamSubscription;
  BehaviorSubject<List<int>>? _audioStream;
  DialogflowGrpcV2Beta1? dialogflow;

  @override
  void initState() {
    super.initState();
    initPlugin();
    // Mensagem inicial acolhedora da assistente Angel para estudantes
    _messages.add(
      const ChatMessage(
        key: Key("welcome"),
        text: "Olá! Sou a Angel, sua assistente no Vozes Livres. Este é um espaço 100% seguro, anônimo e confidencial para estudantes conversarem sobre a escola, bullying, amizades, ansiedade ou pedirem ajuda. Como posso te apoiar hoje?",
        name: "Angel (Assistente)",
        type: false,
      ),
    );
  }

  @override
  void dispose() {
    _recorderStatus?.cancel();
    _audioStreamSubscription?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> initPlugin() async {
    _recorderStatus = _recorder.status.listen((status) {
      if (mounted) {
        setState(() {
          _isRecording = status == SoundStreamStatus.Playing;
        });
      }
    });

    try {
      await _recorder.initialize();
      final String credStr = await rootBundle.loadString('assets/credentials.json');
      final serviceAccount = ServiceAccount.fromString(credStr);
      dialogflow = DialogflowGrpcV2Beta1.viaServiceAccount(serviceAccount);
    } catch (e) {
      // Fallback gracioso se as credenciais do Dialogflow não estiverem presentes
    }
  }

  void stopStream() async {
    await _recorder.stop();
    await _audioStreamSubscription?.cancel();
    await _audioStream?.close();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();

    ChatMessage message = ChatMessage(
      text: text,
      name: "Você",
      type: true,
      key: UniqueKey(),
    );

    setState(() {
      _messages.insert(0, message);
    });
    _scrollToBottom();

    if (dialogflow != null) {
      try {
        DetectIntentResponse data = await dialogflow!.detectIntent(text, 'pt-BR');
        String fulfillmentText = data.queryResult.fulfillmentText;
        if (fulfillmentText.isNotEmpty) {
          ChatMessage botMessage = ChatMessage(
            text: fulfillmentText,
            name: "Angel (Assistente)",
            type: false,
            key: UniqueKey(),
          );

          if (mounted) {
            setState(() {
              _messages.insert(0, botMessage);
            });
            _scrollToBottom();
          }
          return;
        }
      } catch (e) {
        // Fallback de conversa inteligente em português
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));
    String autoReply = _getAutoReply(text);
    ChatMessage botMessage = ChatMessage(
      text: autoReply,
      name: "Angel (Assistente)",
      type: false,
      key: UniqueKey(),
    );

    if (mounted) {
      setState(() {
        _messages.insert(0, botMessage);
      });
      _scrollToBottom();
    }
  }

  String _getAutoReply(String input) {
    final lower = input.toLowerCase();
    if (lower.contains("bullying") || lower.contains("zoando") || lower.contains("xingando") || lower.contains("apelido")) {
      return "O bullying machuca de verdade e você não precisa passar por isso sozinho(a). Nenhum colega tem o direito de te humilhar ou te ameaçar. Você gostaria de orientações sobre como buscar ajuda na orientação educacional ou com o Conselho Tutelar?";
    } else if (lower.contains("cyberbullying") || lower.contains("foto") || lower.contains("internet") || lower.contains("grupo")) {
      return "Sinto muito por isso. Vazamento de fotos ou ofensas em redes sociais são graves. Lembre-se de guardar print das mensagens como prova. Temos informações da SaferNet no app para te ajudar a proteger sua intimidade.";
    } else if (lower.contains("ansiedade") || lower.contains("medo") || lower.contains("prova") || lower.contains("triste")) {
      return "É normal se sentir sobrecarregado(a) às vezes com a escola ou problemas pessoais. Sua saúde mental importa muito! Se quiser desabafar, estou aqui. Também temos o CVV (Ligue 188) para conversa gratuita e sigilosa 24h.";
    } else if (lower.contains("ajuda") || lower.contains("socorro") || lower.contains("emergencia") || lower.contains("perigo")) {
      return "Estou aqui por você! Se estiver em perigo imediato, você pode acionar o Ligue 100 (Proteção a Crianças e Adolescentes) ou 180 na aba de Emergência. Fale comigo: o que está acontecendo?";
    } else if (lower.contains("oi") || lower.contains("olá") || lower.contains("bom dia") || lower.contains("boa tarde")) {
      return "Olá! Seja muito bem-vindo(a). Como estão as coisas na escola hoje?";
    } else {
      return "Estou te ouvindo com atenção. Este é um espaço seguro e anônimo para estudantes. Se precisar de apoio em relação à escola, amizades, saúde mental ou contatos do Conselho Tutelar, é só me contar!";
    }
  }

  void handleStream() async {
    try {
      _recorder.start();

      _audioStream = BehaviorSubject<List<int>>();
      _audioStreamSubscription = _recorder.audioStream.listen((data) {
        _audioStream?.add(data);
      });

      var biasList = SpeechContextV2Beta1(
          phrases: ['Vozes Livres', 'Ajuda', 'Segurança', 'Apoio'],
          boost: 20.0);

      var config = InputConfigV2beta1(
          encoding: 'AUDIO_ENCODING_LINEAR_16',
          languageCode: 'pt-BR',
          sampleRateHertz: 16000,
          singleUtterance: false,
          speechContexts: [biasList]);

      if (dialogflow != null && _audioStream != null) {
        final responseStream = dialogflow!.streamingDetectIntent(config, _audioStream!);

        responseStream.listen((data) {
          if (mounted) {
            setState(() {
              String transcript = data.recognitionResult.transcript;
              String queryText = data.queryResult.queryText;
              String fulfillmentText = data.queryResult.fulfillmentText;

              if (fulfillmentText.isNotEmpty) {
                ChatMessage message = ChatMessage(
                  text: queryText,
                  name: "Você",
                  type: true,
                  key: UniqueKey(),
                );

                ChatMessage botMessage = ChatMessage(
                  text: fulfillmentText,
                  name: "Angel (Assistente)",
                  type: false,
                  key: UniqueKey(),
                );

                _messages.insert(0, message);
                _textController.clear();
                _messages.insert(0, botMessage);
                _scrollToBottom();
              }
              if (transcript.isNotEmpty) {
                _textController.text = transcript;
              }
            });
          }
        });
      }
    } catch (e) {
      // Gravação de áudio
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      if (_isRecording)
        Container(
          width: double.infinity,
          color: const Color(0xFFD32F2F),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: const Text(
            "🔴 Gravando áudio... Fale com clareza",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      Flexible(
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(12.0),
          reverse: true,
          itemBuilder: (_, int index) => _messages[index],
          itemCount: _messages.length,
        ),
      ),
      const Divider(height: 1.0),
      Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: IconTheme(
          data: const IconThemeData(color: Color(0xFF0B2545)),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: handleSubmitted,
                    decoration: InputDecoration(
                      hintText: "Digite sua mensagem...",
                      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF4F7FA),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                CircleAvatar(
                  backgroundColor: const Color(0xFF0B2545),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () => handleSubmitted(_textController.text),
                  ),
                ),
                IconButton(
                  iconSize: 26.0,
                  icon: Icon(
                    _isRecording ? Icons.stop_circle : Icons.mic,
                    color: _isRecording ? const Color(0xFFD32F2F) : const Color(0xFF0066CC),
                  ),
                  onPressed: _isRecording ? stopStream : handleStream,
                ),
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    required final Key key,
    required this.text,
    required this.name,
    required this.type,
  }) : super(key: key);

  final String text;
  final String name;
  final bool type;

  List<Widget> otherMessage(BuildContext context) {
    return <Widget>[
      Container(
        margin: const EdgeInsets.only(right: 10.0),
        child: const CircleAvatar(
          backgroundColor: Color(0xFF0066CC),
          foregroundColor: Colors.white,
          child: Text('A', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0B2545)),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.3),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> myMessage(BuildContext context) {
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0066CC)),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFF0B2545),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0B2545).withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.3),
              ),
            ),
          ],
        ),
      ),
      Container(
        margin: const EdgeInsets.only(left: 10.0),
        child: const CircleAvatar(
          backgroundColor: Color(0xFF0B2545),
          foregroundColor: Colors.white,
          child: Icon(Icons.person, size: 20),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: type ? myMessage(context) : otherMessage(context),
      ),
    );
  }
}


