class Installation {
  final String id, codigo, status;
  final double potenciaKwp;
  final int quantidadeModulos, quantidadeInversores;
  final String modeloModulos, modeloInversores;
  final DateTime? dataPrevisaoEntrega, dataConclusao;
  Installation.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      codigo = json['codigo'] as String? ?? 'Instalação solar',
      status = json['status'] as String? ?? '',
      potenciaKwp = (json['potenciaKwp'] as num?)?.toDouble() ?? 0,
      quantidadeModulos = json['quantidadeModulos'] as int? ?? 0,
      quantidadeInversores = json['quantidadeInversores'] as int? ?? 0,
      modeloModulos = json['modeloModulos'] as String? ?? '',
      modeloInversores = json['modeloInversores'] as String? ?? '',
      dataPrevisaoEntrega = DateTime.tryParse(
        json['dataPrevisaoEntrega'] as String? ?? '',
      ),
      dataConclusao = DateTime.tryParse(json['dataConclusao'] as String? ?? '');
  String get statusLabel => switch (status) {
    'instalacao' || 'em_instalacao' => 'Em instalação',
    'concluido' || 'concluida' || 'finalizado' => 'Concluída',
    'homologacao' || 'em_homologacao' => 'Em homologação',
    'projeto' || 'em_projeto' => 'Em projeto',
    _ => 'Em acompanhamento',
  };
}

class InstallationPage {
  final List<Installation> items;
  final bool hasMore;
  InstallationPage.fromJson(Map<String, dynamic> json)
    : items = (json['items'] as List)
          .map((v) => Installation.fromJson(v as Map<String, dynamic>))
          .toList(),
      hasMore = json['hasMore'] as bool;
}

class InstallationStage {
  final String id, nome, status;
  final DateTime? dataConclusao;
  InstallationStage.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      nome = json['nome'] as String,
      status = json['status'] as String,
      dataConclusao = DateTime.tryParse(json['dataConclusao'] as String? ?? '');
  bool get completed => status == 'concluida';
  String get label => switch (status) {
    'concluida' => 'Concluída',
    'em_andamento' => 'Em andamento',
    'bloqueada' => 'Aguardando resolução',
    _ => 'Pendente',
  };
}

class ClientDocument {
  final String id, nome, tipo;
  ClientDocument.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      nome = json['nome'] as String,
      tipo = json['tipo'] as String? ?? 'Documento';
}
