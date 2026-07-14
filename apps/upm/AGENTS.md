# Cursor handoff: Copland UPM

## Как открыть проект

Всегда открывай именно каталог с пакетным менеджером через **File → Open
Folder**:

```text
<repository>/apps/upm
```

Если UPM уже вынесен в отдельный репозиторий, открывай его корень. Чат Cursor
привязан к workspace, поэтому не работай из empty window.

## Цель проекта

Разрабатывать только пакетный менеджер `upm`. Не изменять Copland ISO,
`iso-profiles`, системные aliases, глобальные compiler flags, локальный
репозиторий пакетов или другие части ОС без отдельного прямого запроса.

UPM предназначен для Copland OS и Arch-совместимых систем:

- официальный backend: `pacman/libalpm + AUR`;
- основа resolver и транзакций: Paru;
- высокоуровневый CLI и recipes: `merclamp/upm`;
- совместимые команды и UX-идеи: `Etersoft/eepm`;
- итоговая лицензия: AGPL-3.0-or-later.

Полное происхождение кода описано в `NOTICE.md`.

## Текущее состояние

Реализовано:

- pacman-совместимые `-S`, `-R`, `-Q`, `-G`, `-B` и остальные операции Paru;
- EPM-style команды `install`, `remove`, `purge`, `update`, `upgrade`,
  `search`, `info`, `status`, `query-file`, `query-package`, `service`,
  `repo`, `cache`, `autoremove`, `doctor`, `toolchain`;
- JSON для read-only команд и диагностики;
- TOML recipes и `upm play`;
- автоматический выбор toolchain;
- compile/link probe для Clang/LLVM;
- чистый однократный fallback на GCC после несовместимой LLVM-сборки;
- немедленный GCC для CUDA и явно GCC-зависимых PKGBUILD;
- сохранение пользовательских `CC`, `CXX`, `AR`, `RANLIB`, `LD`;
- английская и русская документация.

Исходная ветка:

```text
https://github.com/sigmachan/copland-os/tree/cursor/copland-upm-2b20/apps/upm
```

## Архитектура

Основные модули:

- `src/lib.rs` — запуск, конфигурация и маршрутизация операций;
- `src/resolver.rs`, `src/install.rs`, `src/upgrade.rs` — repo+AUR graph и
  транзакции;
- `src/compat.rs` — EPM-style команды, JSON и системные helpers;
- `src/recipe.rs` — поиск и разбор TOML recipes;
- `src/toolchain.rs` — LLVM/GCC detection и compile probe;
- `src/exec.rs` — запуск pacman/makepkg и GCC fallback;
- `recipes/` — встроенные recipes;
- `upm.conf` — пример конфигурации;
- `man/`, `completions/`, `po/` — man pages, completions и локализация.

Не заменяй libalpm разбором локализованного stdout `pacman`. Для resolver и
транзакций сохраняй типизированный libalpm API.

## Toolchain policy

Режим по умолчанию:

```text
UPM_TOOLCHAIN=auto
```

Допустимые значения: `auto`, `llvm`, `gcc`, `system`.

Правила:

1. Не переопределять явно заданные пользователем compiler variables.
2. Не заставлять CUDA использовать Clang как host compiler.
3. Перед выбором LLVM выполнять настоящую compile/link проверку.
4. Fallback разрешён только в `auto` и только один раз после чистой сборки.
5. В human и JSON output показывать фактически выбранный toolchain.

## Безопасность

- Не выполнять partial upgrade.
- Не добавлять сторонние репозитории автоматически.
- Не ослаблять `SigLevel`.
- Перед сборкой AUR сохранять review PKGBUILD и `.SRCINFO`.
- Не выполнять непроверенные post-install shell snippets из recipes.
- Для загрузок требовать checksum/signature, когда они объявлены.
- Не логировать токены, proxy credentials и другие secrets.

## Сборка

Нужна Arch-совместимая система с актуальным `libalpm`:

```sh
sudo pacman -S --needed base-devel rustup clang llvm lld gcc git
rustup default stable
cargo build --release --locked
```

На Ubuntu/Debian WSL не пытайся подменять системный пакетный менеджер. Используй
ArchWSL или Arch container/rootfs с совместимой версией libalpm.

## Обязательные проверки

Перед отправкой изменений:

```sh
cargo fmt --all -- --check
cargo clippy --all-targets --no-default-features -- -D warnings
cargo test --no-default-features
cargo audit
```

Дополнительно проверяй:

```sh
upm doctor --json
upm toolchain --json
UPM_TOOLCHAIN=gcc upm toolchain --json
```

Для изменений fallback обязательно должен оставаться тест
`exec::tests::retries_failed_llvm_makepkg_with_gcc`.

## Git и перенос в merclamp/upm

Желаемый внешний репозиторий:

```text
https://github.com/merclamp/upm
```

Ветка для переноса:

```text
cursor/paru-rewrite-2b20
```

Внешний репозиторий должен содержать содержимое этого каталога в своём корне,
а не весь `copland-os`. Для push необходим Write-доступ GitHub-пользователя и
разрешение Cursor GitHub App на `merclamp/upm`. Никогда не проси пользователя
присылать personal access token в чат.

После получения доступа:

1. создать ветку от `merclamp/upm:master`;
2. заменить дерево ветки содержимым текущего каталога;
3. убедиться, что деревья идентичны;
4. выполнить обязательные проверки;
5. push ветки;
6. создать PR в `master`, сохранив историю авторства и `NOTICE.md`.

## Первый запрос новому Cursor

Можно использовать такой текст:

```text
Открой и прочитай AGENTS.md, README.ru.md и NOTICE.md. Работай только над
пакетным менеджером UPM. Проверь git status, актуальность ветки и доступ к
merclamp/upm. Затем запусти обязательные проверки из AGENTS.md. Если доступ
есть, перенеси содержимое текущего workspace в ветку
cursor/paru-rewrite-2b20 репозитория merclamp/upm и создай PR в master.
```
