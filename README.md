openid-connect-sample
=====================

Google の OpenID Connect 認証を行うサンプルです。

使い方
-----

1. git clone git@github.com:webos-goodies/openid-connect-sample.git
2. bundle install
3. [Google Developer Console](https://console.developers.google.com/) で Client ID と Client secret を取得し、 config/openid_config.yml に設定する。
4. rails s
5. Web ブラウザで http://localhost:3000/ を開く。
6. ログインボタンをクリック。
7. ログインを承認。
