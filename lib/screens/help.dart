import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:safeherven_app/models/organization.dart';
import 'package:safeherven_app/shared/org_card.dart';
import '../shared/appbar.dart';
import '../shared/bottom.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  List<Organization> _allOrganizations = [];
  List<Organization> _filteredOrganizations = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getOrgList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<Organization> _defaultOrganizations = [
    Organization(
      name: "Ligue 100 - Disque Direitos Humanos (Proteção à Criança e Adolescente)",
      description: "Serviço nacional gratuito e anônimo para denúncias e proteção de crianças, adolescentes e estudantes contra abusos, violência e violação de direitos.",
      country: "Brasil",
      location: "Nacional (Discagem 100)",
      telephone: "100",
      email: "disquedireitoshumanos@mdh.gov.br",
      website: "https://www.gov.br/mdh/pt-br/assuntos/disque-100",
      votes: [250],
    ),
    Organization(
      name: "Conselho Tutelar - Apoio à Infância e Juventude",
      description: "Órgão autônomo responsável por zelar pelo cumprimento dos direitos da criança e do adolescente na comunidade e no ambiente escolar.",
      country: "Brasil",
      location: "Municipal",
      telephone: "100",
      email: "conselhotutelar@direitosempre.org",
      website: "https://www.gov.br/mdh/pt-br/navegue-por-temas/crianca-e-adolescente",
      votes: [180],
    ),
    Organization(
      name: "SaferNet Brasil - Combate ao Cyberbullying e Crimes Virtuais",
      description: "Instituição de referência na prevenção e combate ao bullying virtual, vazamento de fotos, ofensas na internet e segurança digital para jovens.",
      country: "Brasil",
      location: "Canal de Ajuda Online",
      telephone: "0800 000 0180",
      email: "helpline@safernet.org.br",
      website: "https://canaldeajuda.safernet.org.br/",
      votes: [165],
    ),
    Organization(
      name: "CVV - Apoio Emocional Escolar & Prevenção",
      description: "Atendimento sigiloso e gratuito 24h para estudantes que enfrentam ansiedade, depressão, momentos difíceis na escola ou precisam conversar.",
      country: "Brasil",
      location: "Nacional (Discagem 188)",
      telephone: "188",
      email: "atendimento@cvv.org.br",
      website: "https://www.cvv.org.br/",
      votes: [210],
    ),
    Organization(
      name: "Central de Atendimento à Mulher - Ligue 180",
      description: "Acolhimento, orientação e encaminhamento para alunas e mulheres em situação de violência doméstica, assédio ou abusos.",
      country: "Brasil",
      location: "Nacional (Discagem 180)",
      telephone: "180",
      email: "ligue180@mdh.gov.br",
      website: "https://www.gov.br/mdh/pt-br/assuntos/violencia-contra-a-mulher",
      votes: [142],
    ),
    Organization(
      name: "Mapa do Acolhimento",
      description: "Rede solidária de psicólogas e advogadas voluntárias oferecendo suporte e escuta atenta gratuita.",
      country: "Brasil",
      location: "Plataforma Online",
      telephone: "0800 000 0180",
      email: "contato@mapadoacolhimento.org",
      website: "https://www.mapadoacolhimento.org/",
      votes: [98],
    ),
  ];

  void _filterOrganizations(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredOrganizations = _allOrganizations;
      });
      return;
    }
    final q = query.toLowerCase();
    setState(() {
      _filteredOrganizations = _allOrganizations.where((org) {
        final name = (org.name ?? '').toLowerCase();
        final desc = (org.description ?? '').toLowerCase();
        final loc = (org.location ?? '').toLowerCase();
        return name.contains(q) || desc.contains(q) || loc.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SafeHervenAppBar('Obter Ajuda', isHome: false),
      bottomNavigationBar: const MenuBottom(currentIndex: 2),
      body: Column(
        children: <Widget>[
          Semantics(
            header: true,
            label: "Cabeçalho de Organizações de Apoio e ONGs",
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: Column(
                children: const [
                  Text(
                    "Organizações de Apoio & ONGs",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B2545),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Lista selecionada de instituições com suporte gratuito, apoio psicológico, orientação jurídica e proteção.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black70,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Semantics(
              label: "Campo para buscar organização por nome, cidade ou serviço",
              child: TextField(
                controller: _searchController,
                onChanged: _filterOrganizations,
                decoration: InputDecoration(
                  hintText: "Buscar ONG ou serviço de apoio...",
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF0066CC)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _filterOrganizations('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: const BorderSide(color: Color(0xFF0066CC), width: 2),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0B2545)),
                  )
                : _filteredOrganizations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              "Nenhuma organização encontrada.",
                              style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: _filteredOrganizations.length,
                        itemBuilder: (context, index) {
                          return OrgCard(ngo: _filteredOrganizations[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> getOrgList() async {
    try {
      var data = await FirebaseFirestore.instance.collection('ngos').get();
      if (data.docs.isNotEmpty) {
        setState(() {
          _allOrganizations = List.from(
            data.docs.map((doc) => Organization.fromSnapshot(doc)),
          );
          _filteredOrganizations = _allOrganizations;
          _isLoading = false;
        });
      } else {
        setState(() {
          _allOrganizations = _defaultOrganizations;
          _filteredOrganizations = _defaultOrganizations;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _allOrganizations = _defaultOrganizations;
        _filteredOrganizations = _defaultOrganizations;
        _isLoading = false;
      });
    }
  }
}


