# Portal Rinnovare — clientes finais

Aplicação Flutter compartilhada entre Web, Android, iOS, Windows, macOS e Linux. A entrada em `lib/main.dart` utiliza exclusivamente `features/portal`; os módulos administrativos antigos não são rotas do aplicativo. Os clientes consultam instalações vinculadas, etapas e documentos publicados. Não há cadastro público, gestão de usuários ou edição de projetos.

## Executar

Use Flutter 3.47.6 / Dart 3.13.5. Execute nesta pasta:

```sh
flutter pub get
flutter test
flutter run -d chrome --dart-define=API_BASE_URL=https://api.rinnovare.com.br/api/v1/app
```

O padrão de `API_BASE_URL` já é essa URL. Em desenvolvimento Web, autorize a origem exata e use uma porta fixa (`--web-port=8080`) no backend. O servidor precisa permitir credenciais CORS e `APP_ALLOWED_ORIGINS`. Hospede a Web em HTTPS no mesmo site `rinnovare.com.br` para os cookies SameSite=Lax; uma origem externa não terá o mesmo comportamento de cookies. Não incorpore chaves Supabase no Flutter.

## Plataformas

| Plataforma | Compilar | Requisitos |
|---|---|---|
| Web | `flutter build web --release` | Hospedagem HTTPS, fallback SPA para index.html e origem autorizada |
| Android | `flutter build apk --debug` | Android SDK, JDK 17, Android 7/API 24 ou posterior (mínimo do Flutter fixado) |
| iOS | `flutter build ios --release --no-codesign` | iOS 15+, macOS e Xcode; assinatura Apple para instalar/distribuir |
| Windows | `flutter build windows --release` | Visual Studio com Desktop C++, ATL e suporte a links simbólicos |
| macOS | `flutter build macos --release` | macOS 12+ e Xcode; assinatura/notarização para distribuição |
| Linux | `flutter build linux --release` | clang, cmake, ninja, GTK3, libsecret e keyring disponível |

O workflow `.github/workflows/client-platforms.yml` testa e compila cada alvo em seu sistema operacional. Seus artefatos não representam publicação nas lojas. Android usa APK de teste; configure uma chave de lançamento privada para gerar AAB de produção. iOS exige Apple Team/provisionamento. O identificador base é `br.com.rinnovare.app`; confirme sua disponibilidade nas contas das lojas antes da publicação.

Para assinar Android, crie `android/key.properties` localmente com `storeFile` (caminho absoluto), `storePassword`, `keyAlias` e `keyPassword`. O arquivo e os keystores são ignorados pelo Git. Release nunca utiliza automaticamente a chave debug; sem a configuração, o artefato não estará assinado para distribuição.

Os artefatos Linux/macOS/iOS contêm um `.tar.gz` dentro do ZIP do GitHub para preservar permissões de execução e links. Extraia primeiro o ZIP, depois o tar (`tar -xzf arquivo.tar.gz`). Windows deve manter o executável junto das DLLs e da pasta `data`; não copiar apenas o `.exe`.

## Sessão e recuperação

Na Web o refresh token fica em cookie HttpOnly do backend; o aplicativo não o salva em localStorage. Nos aplicativos nativos ele fica no armazenamento seguro do sistema. O access token vive somente em memória. Requisições concorrentes compartilham uma renovação de sessão; logout invalida respostas pendentes. macOS usa o Keychain tradicional sem exigir grupo compartilhado; iOS inclui os entitlements do plugin. Android desativa backup para evitar restauração de material criptográfico incompatível.

A recuperação de senha abre o portal Web configurado em `APP_RECOVERY_URL`, com `token_hash` de uso único. Depois de salvar a senha, o cliente pode entrar em qualquer plataforma. Documentos usam links assinados curtos, entregues apenas após verificar vínculo e publicação; a confirmação “Abrir documento” mantém a abertura compatível com bloqueadores de pop-up.

## Implantação coordenada

Domínios definidos: `https://app.cliente.rinnovare.com.br` para o portal e `https://senha.cliente.rinnovare.com.br` para recuperação. Para o segundo, compile com `flutter build web --release --dart-define=PORTAL_RECOVERY_ONLY=true`; esse build abre a recuperação sem restaurar a sessão nem mostrar instalações e oferece retorno ao domínio do app. Links de redefinição usam `?token_hash=...`. Publique cada build na raiz do seu próprio subdomínio.

Na API, as duas origens HTTPS exatas devem constar em `APP_ALLOWED_ORIGINS`, e `APP_RECOVERY_URL=https://senha.cliente.rinnovare.com.br/`. Ative a recuperação somente após DNS/HTTPS, allowlist de redirecionamentos e template condicional no Supabase estarem configurados. Preserve as URLs dos CRMs existentes.

Primeiro prepare a API e a migração descritas em `RinnoTech/api/docs/app-portal.md`, configure a origem real, o template de recuperação e vincule as contas autorizadas. Depois publique `build/web` ou distribua os binários assinados. Sem esse preparo, o frontend não inventa dados: informa indisponibilidade ou ausência de instalações. A migração não altera nem publica automaticamente registros existentes.

Paleta: azul `#0B132B`, verde `#58E514`, verde escuro `#3F7F25`; vidro translúcido, listas sem blur por item e layout adaptável. Texto ampliado e teclado são suportados; não há animação contínua.
