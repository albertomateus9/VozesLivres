import 'package:flutter/material.dart';
import 'package:safeherven_app/models/organization.dart';
import 'package:url_launcher/url_launcher.dart';

class OrgCard extends StatefulWidget {
  final Organization ngo;
  const OrgCard({super.key, required this.ngo});

  @override
  State<OrgCard> createState() => _OrgCardState();
}

class _OrgCardState extends State<OrgCard> {
  int voteCount = 0;

  @override
  void initState() {
    super.initState();
    voteCount = (widget.ngo.votes != null && widget.ngo.votes!.isNotEmpty)
        ? widget.ngo.votes![0]
        : 0;
  }

  Future<void> _callPhone(String phone) async {
    final String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri uri = Uri.parse("tel:$cleanPhone");
    try {
      final launched = await launchUrl(uri);
      if (!mounted) return;
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Não foi possível ligar para $phone")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao discar: $e")),
      );
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri uri = Uri.parse("mailto:$email");
    try {
      final launched = await launchUrl(uri);
      if (!mounted) return;
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Não foi possível enviar e-mail para $email")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao abrir e-mail: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.ngo.name ?? 'Organização de Apoio';
    String country = widget.ngo.country ?? 'Brasil';
    String location = widget.ngo.location ?? 'Nacional';
    String description = widget.ngo.description ?? 'Apoio e acolhimento para mulheres e sobreviventes de violência.';
    String telephone = widget.ngo.telephone ?? '180';
    String email = widget.ngo.email ?? 'contato@vozeslivres.org';

    return Semantics(
      container: true,
      label: "Cartão de suporte de $name em $location",
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        elevation: 3,
        shadowColor: const Color(0xFF0B2545).withValues(alpha: 0.12),
        margin: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: ExpansionTile(
            backgroundColor: Colors.white,
            title: _buildTitle(name, description, country, location, telephone, email),
            trailing: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0066CC)),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        description,
                        style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: <Widget>[
                    InkWell(
                      onTap: () => _callPhone(telephone),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            const Icon(Icons.phone, size: 18, color: Color(0xFF0066CC)),
                            const SizedBox(width: 6),
                            Text(
                              telephone,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0066CC),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => _sendEmail(email),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            const Icon(Icons.email, size: 18, color: Color(0xFF0066CC)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0066CC),
                                  decoration: TextDecoration.underline,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: <Widget>[
                    Semantics(
                      button: true,
                      label: "Votar a favor da organização $name",
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            voteCount++;
                          });
                        },
                        icon: const Icon(Icons.thumb_up_outlined, color: Color(0xFF0066CC)),
                      ),
                    ),
                    const Text("Votar a favor", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const Spacer(),
                    Semantics(
                      button: true,
                      label: "Votar contra a organização $name",
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            if (voteCount > 0) voteCount--;
                          });
                        },
                        icon: const Icon(Icons.thumb_down_outlined, color: Color(0xFFD32F2F)),
                      ),
                    ),
                    const Text("Votar contra", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String name, String description, String country, String location, String telephone, String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          name,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B2545),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "$location • $country",
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Text(
              "$voteCount votos",
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const Spacer(),
            Semantics(
              button: true,
              label: "Visitar site oficial da organização $name",
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B2545),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
                ),
                onPressed: _launchURL,
                label: const Text("Visitar site", style: TextStyle(fontSize: 12)),
                icon: const Icon(Icons.arrow_circle_right, size: 16),
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 6.0, bottom: 2.0),
          child: Center(
            child: Text(
              "Toque para ver mais detalhes",
              style: TextStyle(fontSize: 11, color: Color(0xFF0066CC), fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    );
  }

  Future<void> _launchURL() async {
    final String urlStr = widget.ngo.website ?? 'https://www.gov.br/mdh/pt-br/assuntos/violencia-contra-a-mulher';
    final Uri uri = Uri.parse(urlStr);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Não foi possível abrir: $urlStr")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao abrir link: $e")),
      );
    }
  }
}



