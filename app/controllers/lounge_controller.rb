
class LoungeController < ApplicationController
skip_before_action :verify_authenticity_token
require "securerandom"
  def create
    lounge_uuid = SecureRandom.hex(8)
    lounge = Lounge.new
    lounge.lounge_uuid = lounge_uuid
    lounge.lounge_name = params["lounge_name"]
    lounge.first_group = params["groups"]["first"]
    lounge.second_group = params["groups"]["second"]
    lounge.allow_alone = params["allow_alone"]
    lounge.status = "open"
    lounge.save!
    if params["owner"]
      owner_uuid = SecureRandom.hex(6)
      member = Member.new
      member.member_name = params["owner"]
      member.member_uuid  = owner_uuid
      member.lounge_id = Lounge.find_by(lounge_uuid: lounge_uuid).id
      member.is_owner = true
      member.save!
    end
    response.headers['Access-Control-Allow-Origin'] = '*'
    render :json => {
      "lounge_uuid": lounge_uuid,
      "lounge_name": params["lounge_name"],
      "groups": {
        "first": params["groups"]["first"],
        "second": params["groups"]["second"]
      },
      "alone": params["allow_alone"],
      "owner": {
        "id": owner_uuid,
        "name":params["owner"] #nameはownerが参加する場合のみ送られてくる
      }
    }, status: 200

  end

  def get
    lounge = Lounge.find_by(lounge_uuid: params["lounge_uuid"])

    response.headers['Access-Control-Allow-Origin'] = '*'
    render :json =>   {
      "lounge_id": lounge.id,
      "lounge_name": lounge.lounge_name,
      "groups": {
        "first": lounge.first_group,
        "second": lounge.second_group
      }
    }, status: 200


  end

  def create_member
    lounge = Lounge.find_by(lounge_uuid: params["lounge_uuid"])
    lounge_id = lounge.id
    lounge_status = lounge.status
    member_uuid = SecureRandom.hex(6)
    if lounge_status == "open"
      member = Member.new
      member.member_name = params["name"]
      member.member_uuid = member_uuid
      member.group = params["group"]
      member.lounge_id = lounge_id
      member.thumnail = params["thumnail"]
      member.is_owner = false
      member.save
    else
      render :json =>  "the lounge is closed" ,status: 200 and return
    end
    #thumnailをS3で用意できるように
    response.headers['Access-Control-Allow-Origin'] = '*'
    render :json =>   {
      "lounge_uuid": params["lounge_uuid"],
      "name": params["name"],
      "member_uuid": member_uuid,
      "group": params["group"],
      "thumbnail": params["thumbnail"]
    }, status: 200

  end

  def get_members
    lounge_uuid = params["lounge_uuid"]
    lounge_id = Lounge.find_by(lounge_uuid: lounge_uuid).id
    members = Member.where(lounge_id: lounge_id)
    member_array = []
    members.each do |member|
      member_data = {}
      member_data["member_uuid"] = member.member_uuid
      member_data["member_name"] = member.member_name
      member_data["group"] = member.group
      member_array.push(member_data)
    end

    response.headers['Access-Control-Allow-Origin'] = '*'
    render :json =>   {
      "members": member_array
    }, status: 200
  end

  def fix_members
     owner_uuid = params["owner_uuid"]
     is_owner = Member.find_by(member_uuid: owner_uuid).is_owner
     lounge_id = Member.find_by(member_uuid: owner_uuid).lounge_id
     if is_owner == true
       lounge = Lounge.find_by(id: lounge_id)
       lounge.status = "closed"
       lounge.save

       response.headers['Access-Control-Allow-Origin'] = '*'
       render :json =>  {
         "message": "ok"
       }, status: 200
     else
       response.headers['Access-Control-Allow-Origin'] = '*'
       render :json =>  {"message": "you are not lounge owner"},status: 401
     end
  end

  def register_preference
    member_uuid = params["member_uuid"]
    member_pref = params["preference"]
    member_id = Member.find_by(member_uuid: member_uuid).id
    rank_count = 0
    member_pref.each do |member|
      rank_count += 1
      pref = Pref.new
      pref.member_uuid = member_uuid
      pref.pref_uuid = member["member_uuid"]
      pref.rank = rank_count
      pref.save
    end

    render :json =>  {
      "message": "ok"
    }, status: 200
  end

  def match_result
    response.headers['Access-Control-Allow-Origin'] = '*'
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
