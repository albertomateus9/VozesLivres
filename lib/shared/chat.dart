import 'dart:async';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const List<String> _quickTopics = [
    "Sofrendo bullying",
    "Cyberbullying",
    "Ansiedade / Medo",
    "Preciso de ajuda",
    "Direitos do Estudante",
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      const ChatMessage(
        key: Key("welcome"),
        text:
            "Olá! Sou a Angel, sua assistente local no Vozes Livres. Este é um espaço 100% seguro, anônimo e offline para estudantes conversarem sobre a escola, bullying, amizades, ansiedade ou pedirem ajuda. Como posso te apoiar hoje?",
        name: "Angel (Assistente)",
        type: false,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> handleSubmitted(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _textController.clear();

    final message = ChatMessage(
      text: trimmed,
      name: "Você",
      type: true,
      key: UniqueKey(),
    );

    setState(() {
      _messages.insert(0, message);
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 350));
    final autoReply = _getAutoReply(trimmed);
    final botMessage = ChatMessage(
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
    if (lower.contains("cyberbullying") ||
        lower.contains("foto") ||
        lower.contains("internet") ||
        lower.contains("grupo") ||
        lower.contains("rede")) {
      return "Sinto muito por isso. Vazamento de fotos, montagens ou ofensas em grupos e redes sociais são graves e configuram crime. Guarde prints das mensagens e links como prova e acesse a SaferNet Brasil ou o Ligue 100 na aba 'Ajuda'.";
    } else if (lower.contains("bullying") ||
        lower.contains("zoando") ||
        lower.contains("xingando") ||
        lower.contains("apelido") ||
        lower.contains("agress")) {
      return "O bullying machuca de verdade e você não precisa passar por isso sozinho(a). Nenhum colega tem o direito de te humilhar ou ameaçar. Converse com um adulto de confiança, a coordenação escolar ou acione o Conselho Tutelar pelo Ligue 100.";
    } else if (lower.contains("ansiedade") ||
        lower.contains("medo") ||
        lower.contains("prova") ||
        lower.contains("triste") ||
        lower.contains("chorando") ||
        lower.contains("sozinho")) {
      return "É compreensível se sentir sobrecarregado(a) às vezes. Respire fundo e lembre que você não está só. Se quiser conversar gratuitamente e em sigilo 24h com um voluntário, ligue 188 (CVV) na aba 'Ajuda'.";
    } else if (lower.contains("ajuda") ||
        lower.contains("socorro") ||
        lower.contains("emergencia") ||
        lower.contains("emergência") ||
        lower.contains("perigo") ||
        lower.contains("assédio") ||
        lower.contains("violência")) {
      return "Estou aqui por você! Se estiver em perigo imediato, use o botão vermelho na aba 'Alertas & Emergência' para acionar o Ligue 100 (Direitos Humanos / Infância), o Ligue 180 ou a Polícia Militar (190).";
    } else if (lower.contains("direito") ||
        lower.contains("eca") ||
        lower.contains("lei") ||
        lower.contains("conselho")) {
      return "Pelo Estatuto da Criança e do Adolescente (ECA) e pela Lei 13.185/2015, todas as escolas devem garantir um ambiente seguro e combater o bullying. Você tem direito a acolhimento, sigilo e proteção imediata do Conselho Tutelar.";
    } else if (lower.contains("obrigad")) {
      return "Sempre que precisar, estarei por aqui. Você merece respeito, segurança e paz na escola!";
    } else if (lower.contains("oi") ||
        lower.contains("olá") ||
        lower.contains("ola") ||
        lower.contains("bom dia") ||
        lower.contains("boa tarde") ||
        lower.contains("boa noite")) {
      return "Olá! Seja muito bem-vindo(a). Como você está se sentindo hoje? Pode digitar livremente ou tocar em um dos temas sugeridos abaixo.";
    } else {
      return "Estou te ouvindo com atenção. Todas as conversas ficam apenas no seu dispositivo. Se quiser orientações sobre bullying, segurança digital, ansiedade ou canais gratuitos como Ligue 100 e CVV 188, me conte mais ou escolha uma opção abaixo.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12.0),
            reverse: true,
            itemBuilder: (_, int index) => _messages[index],
            itemCount: _messages.length,
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            itemCount: _quickTopics.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final topic = _quickTopics[index];
              return ActionChip(
                label: Text(
                  topic,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0B2545),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: const Color(0xFFEEF6FF),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                onPressed: () => handleSubmitted(topic),
              );
            },
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
                  const SizedBox(width: 6),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF0B2545),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () => handleSubmitted(_textController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF0B2545),
              ),
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
                    color: Colors.black.withValues(alpha: 0.04),
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF0066CC),
              ),
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
                    color: const Color(0xFF0B2545).withValues(alpha: 0.2),
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
