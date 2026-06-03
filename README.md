
NixOSデスクトップ環境を使用して、ROCK 5T向けのU-Boot + NixOSイメージをクロスコンパイル（エミュレーションビルド）し、インストールする手順をご案内します。

RK3588プラットフォームにおけるNixOSの構築は、コミュニティで実績のあるFlakeリポジトリ（ryan4yin/nixos-rk3588など）をベースにするのが最も近道です。
1. NixOSデスクトップ（ビルドホスト）の準備

x86_64のNixOSデスクトップでARM64向けのイメージをビルドするためには、QEMUを通じたbinfmtエミュレーションを利用するのが最も簡単で確実です。クロスコンパイラ特有のパッケージ依存関係のエラーを回避できます。

デスクトップの configuration.nix に以下を追加して、システムを再構築（nixos-rebuild switch）してください。
Nix

boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

2. Flakeプロジェクトの構築と設定

作業用ディレクトリを作成し、NixOSのビルド構成ファイル（flake.nix 等）を準備します。コミュニティの資産を活用し、ベンダーカーネル（Armbianベースなど）とU-Bootを組み合わせた構成を作ります。  

構築の際の重要な設定ポイントは以下の通りです：

    カーネルパラメータの指定: シリアルコンソールに出力を強制するため、構成ファイル内の boot.kernelParams に console=ttyS2,1500000n8 と earlycon を必ず含めます。

    デバイスツリーの指定: rockchip/rk3588-rock-5t.dtb を指定します。なお、ROCK 5Tのデュアル2.5GbE（RTL8125B）を認識させるためにはPCIeリセットGPIOのパッチ（reset-gpios）をオーバーレイとして当てる必要がある点に注意してください。  

    ファームウェアの統合: U-BootとLinuxカーネルのハードウェア初期化のために、Rockchipの各種ファームウェア（RKNPU用など）や専用のDDR初期化バイナリ（rk3588_spl_loader）を含める記述を行います。

3. SDカードイメージのビルド

Flakeの設定が完了したら、以下のコマンドを実行してインストール用のイメージ（SDカードまたはeMMC用）をビルドします（ターゲット名はFlakeの構成に合わせて変更してください）。
Bash

nix build.#nixosConfigurations.rock5t.config.system.build.sdImage -L

binfmtを利用したカーネルビルドには時間がかかる場合があります。ビルドが成功すると、result/sd-image/ ディレクトリ直下に .img ファイルが生成されます。
4. インストールメディアへの書き込み

生成されたイメージファイルを、SDカードまたはeMMCに書き込みます。
Bash

# /dev/sdX は実際のメディアのデバイス名に置き換えてください
sudo dd if=result/sd-image/nixos-image-xxx-aarch64-linux.img of=/dev/sdX bs=4M status=progress oflag=sync

U-Bootの構成によってはブートローダーの残骸を避けるため、SDカードに書き込む前に dd if=/dev/zero でメディアの先頭部分をゼロクリアしておくことも推奨されます。  

(補足) 以前にEDK2をSPIフラッシュに書き込んでいる場合、設定が競合して起動に失敗する可能性があります。ROCK 5TのMaskromボタンを押しながらPCに接続してMaskromモードで起動し、rkdeveloptool コマンドを使用してSPIフラッシュを消去しておくことをお勧めします。  
5. 起動とシリアルコンソールからの接続

    書き込み済みのSDカード（またはeMMC）をROCK 5Tに挿入します。

    UARTピン（TX, RX, GND）にUSB-TTLシリアルアダプタを接続します。ROCK 5TなどのRockchipボードは 1,500,000 bps (1.5 Mbps) のボーレートを要求するため、CH340やCP2104などの高速通信に対応したチップを搭載したアダプタを使用してください。  

    ホストPC側でシリアルターミナルを開きます。
    Bash

    sudo screen /dev/ttyUSB0 1500000

    ROCK 5Tの電源を入れます。ターミナルにU-Bootの起動ログが表示され、続いてNixOSのLinuxカーネルの起動ログ、最終的にログインプロンプトが表示されれば成功です。

ヘッドレスサーバーとして運用されるとのことですので、シリアルコンソール経由で初期パスワードの設定やIPアドレスの確認を行い、以降はSSH経由で運用を引き継ぐことができます。
