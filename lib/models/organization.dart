class Organization {
  String? name;
  String? description;
  String? country;
  String? location;
  String? telephone;
  String? email;
  String? website;
  List? votes;

  Organization({
    this.name,
    this.description,
    this.country,
    this.location,
    this.telephone,
    this.email,
    this.website,
    this.votes,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'country': country,
        'location': location,
        'telephone': telephone,
        'email': email,
        'website': website,
        'votes': votes
      };

  Organization.fromSnapshot(dynamic snapshot) {
    final Map<String, dynamic> data =
        (snapshot.data() as Map<String, dynamic>?) ?? {};
    name = data['name'] ?? 'Organização de Apoio';
    description = data['description'] ?? 'Sem descrição disponível.';
    country = data['country'] ?? 'Brasil';
    location = data['location'] ?? 'Nacional';
    telephone = data['telephone'] ?? '180';
    email = data['email'] ?? 'contato@safeherven.org';
    website = data['website'] ?? 'https://www.gov.br/mdh/pt-br/assuntos/violencia-contra-a-mulher';
    votes = data['votes'] is List ? data['votes'] : [0];
  }
}