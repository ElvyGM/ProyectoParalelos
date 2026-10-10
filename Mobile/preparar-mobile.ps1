$ErrorActionPreference = 'Stop'
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw 'Flutter no está instalado o no está en PATH. Instale Flutter estable y ejecute flutter doctor.'
}
flutter create --platforms=android,ios .
flutter pub get
flutter analyze
flutter test
