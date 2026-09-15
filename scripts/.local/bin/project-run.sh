#!/usr/bin/env bash
# project-run.sh <build|test|run|lint> <ruta-proyecto>
# Prioridad: justfile > detectores por lenguaje.
set -uo pipefail

ACTION="$1"
D="$2"
cd "$D" || exit 1

has_just_recipe() {
  command -v just >/dev/null 2>&1 || return 1
  { [ -f justfile ] || [ -f Justfile ]; } || return 1
  just --summary 2>/dev/null | tr ' ' '\n' | grep -qx "$ACTION"
}

if has_just_recipe; then
  echo "-> just $ACTION"
  just "$ACTION"
  exit $?
fi

if [ -f CMakeLists.txt ]; then
  case "$ACTION" in
  build) cmake -B build -S . && cmake --build build ;;
  test) ctest --test-dir build --output-on-failure ;;
  run)
    BIN=$(find build -maxdepth 2 -type f -executable ! -name "*.so" ! -name "*.cmake" | head -n1)
    [ -n "$BIN" ] && "$BIN" || echo "No se encontro binario en build/"
    ;;
  lint) command -v clang-tidy >/dev/null && clang-tidy $(find src -name '*.cpp' -o -name '*.c') || echo "clang-tidy no instalado" ;;
  esac

elif [ -f Cargo.toml ]; then
  case "$ACTION" in
  build) cargo build ;;
  test) cargo test ;;
  run) cargo run ;;
  lint) cargo clippy || echo "clippy no instalado (rustup component add clippy)" ;;
  esac

elif [ -f pom.xml ]; then
  case "$ACTION" in
  build) mvn -q compile ;;
  test) mvn -q test ;;
  run) mvn -q exec:java ;;
  lint) mvn -q checkstyle:check || echo "checkstyle no configurado" ;;
  esac

elif [ -f build.gradle ] || [ -f build.gradle.kts ]; then
  GRADLE=$([ -f gradlew ] && echo ./gradlew || echo gradle)
  case "$ACTION" in
  build) $GRADLE build -x test ;;
  test) $GRADLE test ;;
  run) $GRADLE run ;;
  lint) $GRADLE check ;;
  esac

elif [ -f Makefile ] || [ -f makefile ]; then
  case "$ACTION" in
  build) make ;;
  test) make test ;;
  run) make run ;;
  lint) echo "Sin lint definido para Makefile puro" ;;
  esac

elif [ -f go.mod ]; then
  case "$ACTION" in
  build) go build ./... ;;
  test) go test ./... ;;
  run) go run . ;;
  lint) command -v golangci-lint >/dev/null && golangci-lint run || go vet ./... ;;
  esac

elif [ -f pyproject.toml ] || [ -f requirements.txt ] || [ -f setup.py ]; then
  case "$ACTION" in
  build) python3 -m pip install -e . ;;
  test) command -v pytest >/dev/null && pytest || python3 -m pytest ;;
  run) [ -f main.py ] && python3 main.py || echo "No se encontro main.py" ;;
  lint) command -v ruff >/dev/null && ruff check . || python3 -m pyflakes . ;;
  esac

elif ls ./*.ino >/dev/null 2>&1; then
  SKETCH=$(ls ./*.ino | head -n1)
  case "$ACTION" in
  build) command -v arduino-cli >/dev/null && arduino-cli compile . || echo "arduino-cli no instalado" ;;
  run) command -v arduino-cli >/dev/null && arduino-cli upload . || echo "arduino-cli no instalado" ;;
  test | lint) echo "Sin test/lint estandar para sketches de Arduino" ;;
  esac

elif ls ./*.kt >/dev/null 2>&1; then
  case "$ACTION" in
  build) command -v kotlinc >/dev/null && kotlinc ./*.kt -include-runtime -d app.jar || echo "kotlinc no instalado" ;;
  run) [ -f app.jar ] && java -jar app.jar || echo "Compila primero (Build)" ;;
  test | lint) echo "Sin test/lint estandar sin build system" ;;
  esac

elif ls ./*.lua >/dev/null 2>&1; then
  case "$ACTION" in
  build) echo "Lua no requiere build" ;;
  test) command -v busted >/dev/null && busted || echo "busted no instalado" ;;
  run) [ -f main.lua ] && lua5.4 main.lua || echo "No se encontro main.lua" ;;
  lint) command -v luacheck >/dev/null && luacheck . || echo "luacheck no instalado" ;;
  esac

elif ls ./*.sh >/dev/null 2>&1; then
  case "$ACTION" in
  build) echo "Shell no requiere build" ;;
  test | lint) shellcheck ./*.sh ;;
  run)
    MAIN=$(ls ./*.sh | head -n1)
    bash "$MAIN"
    ;;
  esac

else
  echo "No se detecto un lenguaje/marcador conocido en $D"
  exit 1
fi
