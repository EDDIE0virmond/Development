import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/widgets/glass_surface.dart';
import 'card_detail_page.dart';

void openPrivacy(BuildContext context) {
  openCardPage(
    context,
    title: 'Privacidade e dados',
    builder: (_) => const PrivacyPage(),
  );
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  static const sections = <(String, String)>[
    (
      'Quem cuida do acesso',
      'O App Rinnovare é o portal de acompanhamento dos clientes da Rinnovare Solar Engenharia. A equipe libera sua conta e vincula as instalações e usinas que você pode consultar. Contato: projetos@rinnovare.com.br.',
    ),
    (
      'Dados usados no aplicativo',
      'Usamos nome, e-mail e identificação da conta para autenticação e atendimento. O portal apresenta os projetos, etapas, previsões, documentos publicados e dados de geração das usinas vinculadas ao seu cadastro. A senha é enviada por conexão protegida ao serviço de autenticação; o aplicativo não mantém uma cópia legível da senha.',
    ),
    (
      'Sessão e proteção',
      'Em Android e iOS, o token que mantém sua sessão é armazenado no mecanismo seguro do sistema. Na versão Web, usamos cookie de sessão protegido. Sair remove a sessão local. A API verifica seu acesso antes de fornecer os dados. Em aparelhos compartilhados, use Sair ao terminar.',
    ),
    (
      'Serviços que participam',
      'A API Rinnovare intermedeia as consultas ao banco e aos fornecedores de monitoramento. A infraestrutura de hospedagem e autenticação, incluindo Hostinger e Supabase, participa da operação. A recuperação de senha usa o fluxo privado de e-mail operado com n8n e projetos@rinnovare.com.br. O e-mail de recuperação contém um link temporário e não contém sua senha.',
    ),
    (
      'Permissões e consultas',
      'O portal usa acesso à internet para carregar seus dados. O fluxo atual não solicita acesso à câmera, microfone, contatos ou localização do aparelho. Os gráficos são consultados quando você usa o monitoramento; não há monitoramento contínuo do aparelho em segundo plano.',
    ),
    (
      'Conservação e seus pedidos',
      'Os dados do cadastro, projetos e documentos são mantidos nos sistemas da Rinnovare conforme a prestação do serviço e as necessidades de conservação aplicáveis. Encerrar a sessão ou desinstalar o aplicativo não exclui esses registros. Você pode solicitar informações sobre a conservação, correção, revogação do acesso ou exclusão pelo contato abaixo. A equipe verificará sua identidade e informará o atendimento e eventuais necessidades de conservação. Não envie sua senha por e-mail.',
    ),
  ];

  Future<void> _contact(BuildContext context) async {
    try {
      final opened = await launchUrl(
        Uri(
          scheme: 'mailto',
          path: 'projetos@rinnovare.com.br',
          queryParameters: {'subject': 'Privacidade e dados — App Rinnovare'},
        ),
      );
      if (opened) return;
    } catch (_) {
      // The email address remains selectable when no mail application exists.
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Escreva para projetos@rinnovare.com.br. Não envie sua senha.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
    child: GlassSurface(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Atualizado em 26 de outubro de 2026'),
          for (final section in sections) ...[
            const SizedBox(height: 24),
            Text(section.$1, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SelectableText(section.$2, style: const TextStyle(height: 1.55)),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _contact(context),
            icon: const Icon(Icons.mail_outline),
            label: const Text('Solicitar ajuda ou exclusão de dados'),
          ),
        ],
      ),
    ),
  );
}
