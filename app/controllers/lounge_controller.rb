
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
      member.member_name = params["owner"]["name"]
      member.member_uuid  = owner_uuid
      member.lounge_uuid = lounge_uuid
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
      "lounge_uuid": params["lounge_uuid"],
      "lounge_name": lounge.lounge_name,
      "groups": {
        "first": lounge.first_group,
        "second": lounge.second_group
      }
    }, status: 200


  end

  def create_member
    lounge = Lounge.find_by(lounge_uuid: params["lounge_uuid"])
    lounge_status = lounge.status
    member_uuid = SecureRandom.hex(6)
    if lounge_status == "open"
      member = Member.new
      member.member_name = params["name"]
      member.member_uuid = member_uuid
      member.group = params["group"]
      member.lounge_uuid = params["lounge_uuid"]
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
    members = Member.where(lounge_uuid: lounge_uuid)
    member_array = []
    members.each do |member|
      member_data = {}
      member_data["member_uuid"] = member.member_uuid
      member_data["member_name"] = member.member_name
      member_data["group"] = member.group
      member_data["thumbnail"] = member.thumnail
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
     lounge_uuid = Member.find_by(member_uuid: owner_uuid).lounge_uuid
     if is_owner == true
       lounge = Lounge.find_by(lounge_uuid: lounge_uuid)
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
    rank_count = 0
    member_pref.each do |pref_uuid|
      rank_count += 1
      pref = Pref.new
      pref.member_uuid = member_uuid
      pref.pref_uuid = pref_uuid
      pref.rank = rank_count
      pref.save
    end
    member = Member.find_by(member_uuid: member_uuid)
    member.status = "ready"
    member.save

    render :json =>  {
      "message": "ok"
    }, status: 200
  end

  def match_result
    lounge_uuid = params["lounge_uuid"]
    member_uuid = params["member_uuid"]
    lounge_members = Member.where(lounge_uuid: lounge_uuid)
    lounge_member_count = lounge_members.count
    ready_count = Member.where("(lounge_uuid = ?) and (status = ?)", lounge_uuid, "ready").count

    waiting_for = lounge_member_count-ready_count

    if waiting_for > 0
      render :json => {
        "matched_with": nil,
        "waiting_for": waiting_for
      }, status: 200 and return
    else
      #ここでDAアルゴリズみに通す
      allow_alone = Lounge.find_by(lounge_uuid: lounge_uuid).allow_alone

      pref_data = {}
      p(pref_data)
      lounge_members.each do |member|
        member_uuid = member.member_uuid
        group = member.group
        if ! pref_data.has_key?(group)
          pref_data[group] = {}
        end
        pref_data[group][member_uuid] = []
        prefs_array = Pref.where(member_uuid: member_uuid).pluck(:pref_uuid)
        pref_data[group][member_uuid].push(prefs_array).flatten!
      end
      p(pref_data)
      match_hash = DaAlgorithm.main(pref_data,allow_alone)
      p(match_hash)
      p(member_uuid)
      p(match_hash[member_uuid])
      match_uuid = match_hash[member_uuid]
      matched_with = []
      match_uuid.each do |uuid|
        matched_info  = {}
        member = Member.find_by(member_uuid: uuid)
        matched_info["member_uuid"] = uuid
        matched_info["member_name"] = member.member_name
        matched_info["thumbnail"] = member.thumnail
        matched_with.push(matched_info)
      end

      response.headers['Access-Control-Allow-Origin'] = '*'
      render :json =>  {
        "matched_with": matched_with
      }, status: 200
      #マッチした場合
    end
  end
end
