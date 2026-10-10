# MeuAppBiometria

Aplicativo React Native (bare, sem Expo) para iOS com foco em **biometria (Face ID)** e **câmera**, rodando diretamente em iPhone físico via linha de comando, sem depender da interface gráfica do Xcode no dia a dia.

---

## 📋 Pré-requisitos

Tudo o que é necessário para compilar e rodar o app em um iPhone físico a partir do terminal.

### 1. Ferramentas base (via Homebrew)

```sh
brew install node
brew install watchman
brew install rbenv ruby-build
brew install cocoapods       # opcional se for instalar via gem
brew install ios-deploy      # opcional, ajuda em builds alternativos
```

### 2. Ruby 3.x via rbenv (obrigatório)

O macOS vem com Ruby 2.6, que **não** é compatível com as versões recentes do CocoaPods. Por isso usamos `rbenv`:

```sh
# Instala uma versão recente do Ruby
rbenv install 3.4.2
rbenv global 3.4.2
rbenv rehash

# Confirme que está usando o Ruby do rbenv
which ruby      # deve apontar para ~/.rbenv/shims/ruby
ruby -v         # deve mostrar 3.4.2
```

> **Atenção**: se `which ruby` ainda apontar para `/usr/bin/ruby`, verifique se a linha `eval "$(rbenv init - zsh)"` está no final do seu `~/.zshrc` (depois de qualquer bloco do Conda/Anaconda, que costuma sobrescrever o `PATH`).

### 3. CocoaPods

```sh
gem install cocoapods   # sem sudo, pois usa o Ruby do rbenv
pod --version
```

### 4. Xcode e SDK do iOS

- Instale o **Xcode** pela Mac App Store (obrigatório — as Command Line Tools sozinhas **não** bastam para builds de iOS).
- Abra o Xcode uma vez e instale o **iOS SDK** (Componentes → iOS 27.x → Download & Install). Os packs de watchOS, tvOS e visionOS **não** são necessários.
- Nas configurações de "External Agent Access" do Xcode, selecione **"Always"** para permitir builds por linha de comando com o Xcode fechado.

```sh
xcode-select --install     # instala as Command Line Tools
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

### 5. Dependências do projeto

```sh
npm install
cd ios && pod install && cd ..
```

---

## ⚙️ Configurações específicas do projeto (iOS 27+)

Estas configurações **já estão aplicadas** neste repositório, mas ficam documentadas aqui para referência e para novos clones.

### 1. Suporte ao ciclo de vida `UIScene` (obrigatório no iOS 27+)

O iOS 27 **exige** o uso de `UIScene`. Sem ele, o app abre com **tela preta** (a janela é criada, mas nunca é anexada à cena visível).

**Arquivos envolvidos:**

- `ios/MeuAppBiometria/SceneDelegate.swift` — cria a `UIWindow(windowScene:)` e chama `startReactNative` **depois** da janela estar vinculada à cena.
- `ios/MeuAppBiometria/AppDelegate.swift` — apenas prepara a `RCTReactNativeFactory`, sem criar janela.
- `ios/MeuAppBiometria/Info.plist` — declara `UIApplicationSceneManifest` com `UISceneDelegateClassName = $(PRODUCT_MODULE_NAME).SceneDelegate`.

> **Importante**: o `SceneDelegate.swift` precisa estar no **target** `MeuAppBiometria` (Target Membership marcada no Xcode). Se não estiver, o build passa, mas o app fica em tela preta.

### 2. Desativar `User Script Sandboxing`

O React Native precisa escrever o arquivo `ip.txt` dentro do `.app` durante o build de debug, o que é bloqueado pelo sandbox padrão do Xcode 15+.

No Xcode, em **Build Settings**, defina:

```
ENABLE_USER_SCRIPT_SANDBOXING = NO
```

Tanto no nível **PROJECT** quanto no **TARGET**.

---

## 🚀 Como rodar o app

### Passo 1: Inicie o Metro Bundler

Em um terminal, na raiz do projeto:

```sh
npx react-native start
```

> Se algo parecer travado ou o bundle não atualizar, use `--reset-cache`:
>
> ```sh
> npx react-native start --reset-cache
> ```

### Passo 2: Compile e instale no iPhone

Em um **segundo terminal**, na raiz do projeto:

```sh
npx react-native run-ios --device "iPhone"
```

> Substitua `"iPhone"` pelo nome exato que aparece em **Ajustes > Geral > Sobre** no aparelho, ou pelo que aparecer em `xcrun devicectl list devices`.

O comando irá:

1. Compilar o código nativo com `xcodebuild`.
2. Assinar o app com o perfil de desenvolvimento configurado.
3. Instalar o `.app` no iPhone via `devicectl`.
4. Iniciar o app automaticamente.

### Passo 3: Primeira execução — confiar no desenvolvedor

Na **primeira instalação** de um app com conta gratuita (Personal Team), o iPhone bloqueia a execução. Para liberar:

1. No iPhone: **Ajustes > Geral > VPN e Gerenciamento de Dispositivo**.
2. Toque no perfil **"Apple Development: seu@email.com"**.
3. Toque em **"Confiar em ..."** e confirme.

> Esse perfil de confiança expira a cada **7 dias** com conta gratuita. Quando expirar, basta rodar o `run-ios` novamente para reinstalar.

---

## 🔍 Debug e logs

### Ver logs do app em tempo real

Com o app instalado, use `devicectl` para lançar o app capturando stdout/stderr:

```sh
xcrun devicectl device process launch \
  --console \
  --device <UDID_DO_IPHONE> \
  com.rafaelaraujo.meuappbiometria
```

Para descobrir o UDID do iPhone:

```sh
xcrun devicectl list devices
```

### Menu de desenvolvedor no iOS

Com o app em execução no dispositivo físico:

- **Agitar o iPhone** → abre o Dev Menu.
- Ou, com o app em foco no simulador, pressione `Cmd + D`.
- Opções úteis: **Reload**, **Open Debugger**, **Toggle Performance Monitor**.

### Verificar se o Metro está respondendo

```sh
curl http://localhost:8081/status
# resposta esperada: packager-status:running
```

### Verificar conectividade entre iPhone e Metro

Descubra o IP local do Mac:

```sh
ipconfig getifaddr en0
```

No iPhone, abra o Safari e acesse `http://<IP_DO_MAC>:8081/status`. Se retornar `packager-status:running`, a rede está OK. **O iPhone e o Mac precisam estar na mesma rede Wi-Fi.**

### Logs do dispositivo via linha de comando (alternativa)

```sh
brew install libimobiledevice
idevicesyslog -u <UDID_DO_IPHONE> | grep -i "MeuAppBiometria"
```

---

## 🧹 Limpeza e reset

### Limpar build do React Native

```sh
npx react-native clean
```

### Reinstalar pods

```sh
cd ios && pod install && cd ..
```

### Reset completo (último recurso)

```sh
# Remove DerivedData do projeto
rm -rf ~/Library/Developer/Xcode/DerivedData/MeuAppBiometria-*

# Remove Pods e reinstala
cd ios
rm -rf Pods Podfile.lock build
pod install
cd ..

# Recompila
npx react-native run-ios --device "iPhone"
```

---

## 🐛 Problemas comuns e soluções

| Sintoma                                       | Causa provável                   | Solução                                                |
| --------------------------------------------- | -------------------------------- | ------------------------------------------------------ |
| `requires a development team`                 | Team não configurado             | Abrir Xcode → Signing & Capabilities → selecionar Team |
| Tela preta ao abrir                           | `UIScene` não configurado        | Verificar `SceneDelegate.swift` e `Info.plist`         |
| `Sandbox: deny file-write-data`               | Sandboxing ativo                 | `ENABLE_USER_SCRIPT_SANDBOXING = NO`                   |
| `Could not connect to development server`     | iPhone e Mac em redes diferentes | Conectar ambos no mesmo Wi-Fi                          |
| App fecha logo após abrir                     | Perfil de desenvolvedor expirado | Rodar `run-ios` novamente                              |
| `Unable to launch ... not explicitly trusted` | Falta confiar no perfil          | Ajustes > Geral > VPN e Gerenciamento                  |
| `plutil: Found non-key inside <dict>`         | `Info.plist` malformado          | Validar com `plutil -lint`                             |

---

## 🛠️ Comandos úteis

```sh
# Listar dispositivos conectados
xcrun devicectl list devices

# Validar sintaxe do Info.plist
plutil -lint ios/MeuAppBiometria/Info.plist

# Ver versão do Ruby ativa
ruby -v && which ruby

# Ver IP local do Mac
ipconfig getifaddr en0

# Diagnóstico do ambiente React Native
npx react-native doctor
```

---

## 📚 Referências

- [React Native — Environment Setup](https://reactnative.dev/docs/set-up-your-environment)
- [React Native — Troubleshooting](https://reactnative.dev/docs/troubleshooting)
- [Apple — UIScene Lifecycle](https://developer.apple.com/documentation/uikit/app_and_environment/managing_your_app_s_life_cycle)
- [CocoaPods Getting Started](https://guides.cocoapods.org/using/getting-started.html)
- [rbenv](https://github.com/rbenv/rbenv)
