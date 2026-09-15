#!/usr/bin/env bash
# project-doctor.sh — verifica que herramientas de desarrollo estan instaladas
echo "=== Project Doctor ==="
echo

check() {
  local bin="$1" label="$2"
  if command -v "$bin" >/dev/null 2>&1; then
    printf "  \033[1;32m✓\033[0m %-15s %s\n" "$bin" "$label"
  else
    printf "  \033[1;31m✗\033[0m %-15s %s (falta)\n" "$bin" "$label"
  fi
}

echo "General:"
check just "Justfile runner"
check fzf "Selector fuzzy"
check eza "Listados con arbol"
check git "Control de versiones"
echo

echo "C/C++:"
check gcc "Compilador C"
check g++ "Compilador C++"
check cmake "Build system"
check ctest "Test runner CMake"
check make "Build system clasico"
check clang-tidy "Linter C/C++"
echo

echo "Go:"
check go "Toolchain Go"
check golangci-lint "Linter Go"
echo

echo "Python:"
check python3 "Interprete"
python3 -m pip --version >/dev/null 2>&1 && printf "  \033[1;32m✓\033[0m %-15s %s\n" "pip" "Gestor de paquetes" || printf "  \033[1;31m✗\033[0m %-15s %s (falta)\n" "pip" "Gestor de paquetes"
check pytest "Test runner"
check ruff "Linter/formatter"
echo

echo "Lua:"
check lua5.4 "Interprete"
check luarocks "Gestor de paquetes"
check luacheck "Linter"
check busted "Test runner"
echo

echo "Bash/Shell:"
check shellcheck "Linter"

echo "Rust:"
check rustc "Compilador"
check cargo "Gestor de paquetes/build"
check clippy-driver "Linter (via rustup component)"
echo

echo "Java/Kotlin:"
check java "JRE/JDK"
check javac "Compilador Java"
check kotlinc "Compilador Kotlin"
check mvn "Maven"
check gradle "Gradle"
echo

echo "Arduino:"
check arduino-cli "CLI de Arduino"
echo

echo "GitHub:"
check gh "GitHub CLI"
