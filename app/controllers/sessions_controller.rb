# -*- coding: utf-8 -*-

require 'openid-connect'

class SessionsController < ApplicationController

  # ログインの開始（権限の承認ページヘのリダイレクト）
  def new
    reset_session

    # OpenIDConnectクラスのインスタンスを作成。
    # 引数はRailsのセッションオブジェクトとコールバックURL
    oc = OpenIDConnect.new(session, session_url)

    # 承認ページのURLを構築し、そこへリダイレクトする。
    # 引数は、スコープと OpenID 2.0 の realm。
    redirect_to oc.authentication_url('openid email profile', root_url)
  end

  # コールバックの処理
  def show
    # OpenIDConnectクラスのインスタンスを作成。
    # 引数はRailsのセッションオブジェクトとコールバックURL
    oc      = OpenIDConnect.new(session, session_url)

    # 引き渡された code をアクセストークンに交換する
    # 引数はクエリーパラメータを格納したHash
    @result = oc.authentication_result(params)

    # id_tokeをパースして中身を返す
    # 引数はauthentication_resultの返り値
    @payload = oc.parse_id_token(@result)

    # プロファイル情報を取得
    # 引数はauthentication_resultの返り値
    @profile = oc.retrieve_profile(@result)

    @error = nil

  # エラーが発生したときは以下の例外が投げられる
  rescue OpenIDConnect::CancelError
    @error = "認証がキャンセルされました"
  rescue OpenIDConnect::InvalidTokenError
    @error = "state パラメータが異なっています"
  rescue OpenIDConnect::ExchangeError
    @error = "アクセストークンの取得に失敗しました"
  rescue OpenIDConnect::IdTokenError => e
    @error = "id_tokenのパースに失敗しました"
  end

end
