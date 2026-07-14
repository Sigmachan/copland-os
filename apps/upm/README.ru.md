# Copland UPM

[English](README.md)

`upm` — пакетный менеджер для Copland OS и других Arch-совместимых систем.
Он работает с официальными репозиториями, локальными репозиториями и AUR,
сохраняя совместимость с привычными операциями `pacman`.

Контекст и готовый запрос для нового окна Cursor находятся в
[AGENTS.md](AGENTS.md).

## Из чего состоит проект

- **Paru** — основа: libalpm, разрешение зависимостей repo+AUR, транзакции,
  просмотр PKGBUILD, обновление `-git` пакетов, chroot-сборки и Arch News.
- **merclamp/upm** — высокоуровневые команды, JSON-диагностика и TOML-рецепты.
- **Etersoft/eepm** — единый человекочитаемый словарь команд: `install`,
  `remove`, `search`, `status`, `service`, `repo`, `cache` и другие.
- **Copland UPM** — автоматический выбор LLVM/GCC, безопасный fallback,
  Arch-only backend и совместимость с синтаксисом Paru/pacman.

Исходный код объединён и существенно переработан. Подробности об авторах и
лицензиях находятся в [NOTICE.md](NOTICE.md).

## Требования

- Arch Linux, Copland OS, Garuda, CachyOS или другая система с актуальным
  `pacman` и `libalpm`;
- Rust stable;
- `base-devel`, Git и GnuPG;
- Clang/LLVM/lld для основного режима сборки;
- GCC как совместимый fallback.

На Ubuntu/Debian WSL проект штатно не запускается: там отсутствуют нативные
pacman и libalpm нужной версии. Для WSL используйте ArchWSL либо другую
Arch-совместимую rootfs.

## Сборка из исходников

```sh
sudo pacman -S --needed base-devel rustup clang llvm lld gcc git
rustup default stable
git clone --branch cursor/copland-upm-2b20 \
  https://github.com/sigmachan/copland-os.git
cd copland-os/apps/upm
cargo build --release --locked
sudo install -Dm755 target/release/upm /usr/local/bin/upm
```

Проверка:

```sh
upm doctor
upm toolchain --json
upm --help
```

## Основные команды

```sh
upm                         # полное обновление, аналог upm -Syu
upm -S firefox              # pacman/Paru-совместимый синтаксис
upm install firefox         # EPM-совместимый синтаксис
upm remove firefox
upm purge firefox
upm update
upm upgrade
upm search firefox
upm info firefox
upm status firefox
upm query-file /usr/bin/git
upm list --installed
upm list --foreign
upm autoremove --dry-run
upm service status docker
upm repo list
upm cache status
```

Для read-only команд поддерживается машинный вывод:

```sh
upm search firefox --output=json
upm doctor --json
upm toolchain --json
```

## Repo и AUR

Одна транзакция разрешает зависимости из официальных репозиториев и AUR.
Перед сборкой AUR-пакета UPM показывает PKGBUILD и `.SRCINFO`, поддерживает
проверку PGP-ключей, отслеживает development-пакеты и не выполняет частичное
обновление системы.

Низкоуровневые операции остаются совместимыми с pacman:

```sh
upm -Syu
upm -Ss запрос
upm -Qi пакет
upm -Qo /путь/к/файлу
upm -G aur-пакет
upm -Bi .
```

## LLVM и fallback на GCC

По умолчанию действует `UPM_TOOLCHAIN=auto`:

1. UPM проверяет наличие `clang`, `clang++`, LLVM tools и lld.
2. Выполняет реальную пробную компиляцию и линковку.
3. Передаёт выбранные `CC`, `CXX`, `AR`, `RANLIB` и `LD` в `makepkg`.
4. При несовместимой LLVM-сборке выполняет один чистый повтор через GCC.
5. Для CUDA и PKGBUILD с явным GCC сразу выбирает GCC.

Режим можно зафиксировать:

```sh
UPM_TOOLCHAIN=llvm upm -S пакет
UPM_TOOLCHAIN=gcc upm -S пакет
UPM_TOOLCHAIN=system upm -S пакет
```

Если пользователь уже определил `CC`, `CXX`, `AR`, `RANLIB` или `LD`, UPM не
перезаписывает эти значения.

## Рецепты

Команда `upm play имя` ищет TOML-рецепт в следующем порядке:

1. `$UPM_RECIPE_DIR`;
2. `$XDG_CONFIG_HOME/upm/recipes`;
3. `/usr/share/upm/recipes`;
4. каталог `recipes` рядом с исходниками.

Минимальный рецепт:

```toml
name = "example"
description = "Пример приложения"

[packages]
pacman = ["example", "example-docs"]
```

Если рецепта нет, имя передаётся обычному resolver и ищется в репозиториях/AUR.

## Конфигурация и диагностика

Основной конфиг: `/etc/upm.conf`. Пользовательский конфиг:
`~/.config/upm/upm.conf`.

```sh
upm doctor
upm doctor --json
UPM_DEBUG=1 upm -S пакет
```

Дополнительная документация устанавливается как `upm(8)` и `upm.conf(5)`.

## Ограничения

- Реализован только backend `pacman/libalpm + AUR`.
- `repack` требует внешний конвертер, например `debtap`.
- Автоматическое добавление сторонних репозиториев намеренно запрещено:
  ключи и `SigLevel` необходимо проверять вручную.
- UPM не заменяет `pacman` как системную библиотеку или backend установщика.
