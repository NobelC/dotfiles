#!/usr/bin/env bash
# project-new.sh — crea un proyecto nuevo con justfile listo para usar,
# opcionalmente conectado a un repo remoto de GitHub.
set -uo pipefail

PROJECTS_DIR="${PROJECTS_DIR:-$HOME/GitHub-Repo}"

LANG=$(printf "cpp\nc\ngo\nrust\npython\njava\nkotlin\nbash\nlua\narduino" | fzf --height=40% --border --prompt='Lenguaje  ')
[ -z "$LANG" ] && exit 0

read -rp "Nombre del proyecto: " NAME
[ -z "$NAME" ] && {
  echo "Nombre vacio, cancelado."
  exit 1
}

DEST="$PROJECTS_DIR/$NAME"
[ -d "$DEST" ] && {
  echo "Ya existe: $DEST"
  read -rp "ENTER para continuar..." _
  exit 1
}

REMOTE="Solo local"
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  REMOTE=$(printf "Solo local\nLocal + GitHub (privado)\nLocal + GitHub (publico)" | fzf --height=30% --border --prompt='Repositorio  ')
  [ -z "$REMOTE" ] && exit 0
fi

mkdir -p "$DEST"
cd "$DEST" || exit 1
git init -q

case "$LANG" in
cpp | c)
  mkdir -p src include build
  EXT=$([ "$LANG" = "cpp" ] && echo cpp || echo c)
  cat >CMakeLists.txt <<EOF
cmake_minimum_required(VERSION 3.20)
project($NAME)
set(CMAKE_CXX_STANDARD 20)
add_executable($NAME src/main.$EXT)
EOF
  if [ "$LANG" = "cpp" ]; then
    printf '#include <iostream>\nint main() { std::cout << "Hello, %s!\\n"; }\n' "$NAME" >"src/main.$EXT"
  else
    printf '#include <stdio.h>\nint main() { printf("Hello, %s!\\n"); return 0; }\n' "$NAME" >"src/main.$EXT"
  fi
  cat >justfile <<'EOF'
build:
    cmake -B build -S .
    cmake --build build

test:
    ctest --test-dir build --output-on-failure

run: build
    ./build/PROJECT_NAME

lint:
    clang-tidy src/*.c* -- -Iinclude
EOF
  sed -i "s/PROJECT_NAME/$NAME/" justfile
  ;;
go)
  go mod init "$NAME" >/dev/null 2>&1
  printf 'package main\n\nimport "fmt"\n\nfunc main() {\n\tfmt.Println("Hello, %s!")\n}\n' "$NAME" >main.go
  cat >justfile <<'EOF'
build:
    go build ./...

test:
    go test ./...

run:
    go run .

lint:
    go vet ./...
EOF
  ;;
rust)
  cargo init --name "$NAME" -q
  cat >justfile <<'EOF'
build:
    cargo build

test:
    cargo test

run:
    cargo run

lint:
    cargo clippy
EOF
  ;;
python)
  printf 'def main():\n    print("Hello, %s!")\n\nif __name__ == "__main__":\n    main()\n' "$NAME" >main.py
  cat >pyproject.toml <<EOF
[project]
name = "$NAME"
version = "0.1.0"
EOF
  cat >justfile <<'EOF'
build:
    python3 -m pip install -e .

test:
    pytest

run:
    python3 main.py

lint:
    ruff check .
EOF
  ;;
java)
  mkdir -p src/main/java
  cat >"src/main/java/Main.java" <<EOF
public class Main {
    public static void main(String[] args) {
        System.out.println("Hello, $NAME!");
    }
}
EOF
  cat >justfile <<EOF
build:
    javac -d build src/main/java/Main.java

run: build
    java -cp build Main

test:
    echo "Configura JUnit para tests"

lint:
    echo "Configura checkstyle para lint"
EOF
  ;;
kotlin)
  printf 'fun main() {\n    println("Hello, %s!")\n}\n' "$NAME" >main.kt
  cat >justfile <<'EOF'
build:
    kotlinc main.kt -include-runtime -d app.jar

run: build
    java -jar app.jar

test:
    echo "Configura kotlin.test para tests"

lint:
    echo "Configura ktlint para lint"
EOF
  ;;
bash)
  printf '#!/usr/bin/env bash\nset -euo pipefail\necho "Hello, %s!"\n' "$NAME" >"$NAME.sh"
  chmod +x "$NAME.sh"
  cat >justfile <<EOF
run:
    ./$NAME.sh

lint:
    shellcheck *.sh
EOF
  ;;
lua)
  printf 'print("Hello, %s!")\n' "$NAME" >main.lua
  cat >justfile <<'EOF'
run:
    lua5.4 main.lua

test:
    busted

lint:
    luacheck .
EOF
  ;;
arduino)
  mkdir -p "$NAME"
  cat >"$NAME/$NAME.ino" <<EOF
void setup() {
  Serial.begin(9600);
}

void loop() {
  Serial.println("Hello, $NAME!");
  delay(1000);
}
EOF
  cat >justfile <<'EOF'
build:
    arduino-cli compile .

run:
    arduino-cli upload .
EOF
  ;;
esac

cat >README.md <<EOF
# $NAME
EOF

git add -A
git commit -q -m "chore: scaffold inicial ($LANG)"

case "$REMOTE" in
"Local + GitHub (privado)")
  gh repo create "$NAME" --private --source=. --remote=origin --push
  ;;
"Local + GitHub (publico)")
  gh repo create "$NAME" --public --source=. --remote=origin --push
  ;;
esac

echo "Proyecto creado en $DEST"
read -rp "Presiona ENTER para continuar..." _
