# Mt4_develop

MT4で動作する自動売買プログラム(EA)です。

> MetaTrader(MT)は、外国為替証拠金取引投資家が利用する電子取引プラットフォームである。MetaQuotes Softwareによって開発され2005年にリリースされた。ソフトウェアは、クライアントにソフトウェアを提供する外国為替業者によりライセンスされており、クライアントとサーバーの両コンポーネントで構成されている。 サーバコンポーネントは業者が担当し、クライアントソフトウェアでは顧客が価格とチャートを表示し注文やアカウント管理を行う。(https://ja.wikipedia.org/wiki/MetaTrader)

## Note

一部の売買アルゴリズムについて簡単に説明します。
- Envelope_scalping
  - 単純移動平均線の上[下]エンベロープ(-5σから+5σで設定可）に価格が到達したとき、ショート[ロング]でエントリーする。
  - 価格が予め定めた利確値もしくは損切値に到達した際は決済する。
  - 決済の際、損益がマイナスであった場合は以後1時間は取引を行わない。

- IFD_sample
  - ポジションを持たないときは予め定めた利確値を設定し、ロング[ショート]で即座にエントリーする。
  - あらかじめ定めた値幅の下落[上昇]があった場合は加えてロング[ショート]でエントリーする。

- trail_ryoudate_v2
  - ポジションを持たないときはロング[ショート]で即座にエントリーする。
  - 予め設定した値幅にてトレーリングストップを実装している。
  
> トレーリングストップとは高値安値に合わせて、逆指値注文をリアルタイムに自動修正する機能を追加した自動売買です。
売りの場合であれば、「株価が下落した場合には逆指値で売却し、上昇した場合には売却する価格を
自動的に切り上げ、株価の値上がりに追従する」ということが可能になります。
買いの場合は売りとは逆に、株価の値下がりに追従することが可能です。  (https://kabucom.custhelp.com/app/answers/detail/a_id/777)

## Caution

著作権上の問題があるため私が引用して用いている一部の関数はインクルードファイルにて隠蔽しています。
検索すればヒットするはずです。

## Author  
xianGuiye

