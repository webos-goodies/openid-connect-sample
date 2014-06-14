openid-connect-sample
=====================

Google の OpenID Connect 認証を行うサンプルです。

使い方
-----

1. `git clone git@github.com:webos-goodies/openid-connect-sample.git`
2. `bundle install`
3. [Google Developer Console](https://console.developers.google.com/) で Client ID と Client secret を取得し、 config/openid_config.yml に設定する。
	* Javascript Origins には http://localhost:3000 を、Redirect URIs には https://localhost:3000/session を指定する。
4. `rails s`
5. Web ブラウザで http://localhost:3000/ を開く。
6. ログインボタンをクリック。
7. ログインを承認。
8. 取得した情報を下のスクリーンショットのように表示します。

![認証後の画面](http://cache.webos-goodies.jp/cache/farm8.staticflickr.com/7185/13997444194_490d6760f1_o.png)
