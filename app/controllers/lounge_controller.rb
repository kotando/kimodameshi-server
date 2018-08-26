
class LoungeController < ApplicationController
  def create
    #params["lounge_name"]
    #params["groups"]
    #pamrams["allow_alone"]
    #params["owner"]

    render :json => {
      "lounge_id": "3f2falfajweagawe2",
      "lounge_name": "hogehoge",
      "groups": {
        "first": "男",
        "second": "女"
      },
      "alone": true,
      "owner": {
        "id": "7ehf7heyuin866",
        "name": "hogehoge"  #nameはownerが参加する場合のみ送られてくる
      }
    }, status: 200

  end

  def get
    #params["lounge_id"]


    render :json =>   {
        "lounge_id": "3f2falfajweagawe2",
        "lounge_name": "hogehoge",
        "groups": {
          "first": "男",
          "second": "女"
        }
      }, status: 200


  end

  def create_member
      #params["lounge_id"]
      #params["lounge_name"]
      #params["groups"]
      render :json =>   {
        "lounge_id": "3f2falfajweagawe2",
        "lounge_name": "hogehoge",
        "groups": {
          "first": "男",
          "second": "女"
        }
      }, status: 200

  end

  def get_members
    #params["lounge_id"]

    render :json =>   {
      "members": [
        {
          "member_id": "345y6dwhw00er",
          "member_name": "hogehoge",
          "group": "first"
        },
        {
            "member_id": "444g4df4wmfu7",
            "member_name": "mugemuge",
            "group": "second"
        },
        {
            "member_id": "734gdfgwwm449",
            "member_name": "pagepage",
            "group": "first"
        }
      ]
    }, status: 200
  end

  def fix_members

    render :json =>  {
      "message": "ok"
    }, status: 200

  end

  def resister_preference
    render :json =>  {
      "message": "ok"
    }, status: 200
  end

  def match_result
    render :json =>  {
      "matched_with": [
          {
            "member_id": "77gdfgwhwmfu7",
            "member_name": "hogehoge"
          }
      ]
    }, status: 200
    #マッチした場合
  end
end
