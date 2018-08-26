class DaAlgorithm
  require 'securerandom'

  def self.da_algorithm(pref_data)
      if pref_data['first'].count > pref_data['second'].count then
          offerer_s  = pref_data['second']
          accepter_s = pref_data['first']
      else
          offerer_s  = pref_data['first']
          accepter_s = pref_data['second']
      end
      matched = [] # マッチングした人を保存
      temp = {}    # マッチング相手とその選好順位を保存
      result = {}  # マッチング結果を保存
      while matched.count != offerer_s.count do

          # グループ１から一人ずつ以下の処理をする
          for offerer in offerer_s.keys do

              # マッチ済みのメンバーはこれ以降の処理をスキップ
              if matched.include?(offerer) then
                  next
              end

              # 自分（offerer）の選好のリストを取得
              prefs = offerer_s[offerer]
              for p in prefs do

                  # ターゲット(p)の選好に自分(offerer)がいる場合
                  if accepter_s[p].include?(offerer) then
                      rank = accepter_s[p].index(offerer)

                      # ターゲット（p）がすで他の人とマッチしていた場合
                      if temp.has_key?(p) then
                          # 選好順位が自分の方が高い場合
                          if rank < temp[p]['rank'] then
                              matched.push(offerer)
                              matched.delete(temp[p]['offerer'])
                              result[offerer] = p
                              result.delete(temp[p]['offerer'])
                              temp[p]['rank'] = rank
                              temp[p]['offerer'] = offerer
                              break
                          end

                      # ターゲット（p）がまだ誰ともマッチしていない場合
                      else
                          matched.push(offerer)
                          result[offerer] = p
                          temp[p] = {
                              'rank'=> rank,
                              'offerer'=> offerer
                          }
                          break
                      end
                  end
              end
              # どのターゲットともマッチしていない場合
              if !(result.include?(offerer)) then
                  # 存在しない人（None）とマッチしたとする
                  matched.push(offerer)
                  result[offerer] = nil
              end
          end
      end
      return result
  end


  def self.cal_matching_rate(pref_data, matching_result)
      if pref_data['first'].count > pref_data['second'].count then
          offerer_s  = pref_data['second']
          accepter_s = pref_data['first']
      else
          offerer_s  = pref_data['first']
          accepter_s = pref_data['second']
      end
      result = {}

      for offerer in matching_result.keys do
          accepter = matching_result[offerer]

          if accepter == nil then
              next
          else
              # 順位の和が小さいほどマッチ度が強い
              rank1 = offerer_s[offerer].index(accepter)
              rank2 = accepter_s[accepter].index(offerer)
              result[offerer] = rank1 + rank2
          end
      end

      return result
  end


  def self.get_non_matched_offerers(pref_data, matching_result)
      offerer_s = []
      matching_result.each do |k, v|
          if v == nil then
              offerer_s.push(k)
          end
      end
      return offerer_s
  end


  def self.get_non_matched_accepters(pref_data, matching_result)
      accepter_s = pref_data['second'].keys
      for accepter in matching_result.values do
          if !(accepter == nil) then
              accepter_s.delete(accepter)
          end
      end
      return accepter_s
  end


  def self.transform_dict_stracture(dic)
      result = {}
      dic.each do |k, v|
          if v == nil then
              result[k] = []
          else
              result[k] = [v]
          end
      end
      return result
  end


  def self.sort_offerers(matching_rate)
      temp = []
      for items in matching_rate.sort_by{|k, v| v}.reverse do
          temp.push(items[0])
      end
      return temp
  end


  def self.regroup(pref_data, matching_result)
      if pref_data['first'].count > pref_data['second'].count then
          offerer_s  = pref_data['second']
          accepter_s = pref_data['first']
      else
          offerer_s  = pref_data['first']
          accepter_s = pref_data['second']
      end
      non_matched_offerers  = DaAlgorithm.get_non_matched_offerers(pref_data, matching_result)
      non_matched_accepters = DaAlgorithm.get_non_matched_accepters(pref_data, matching_result)
      matching_rate = DaAlgorithm.cal_matching_rate(pref_data, matching_result)

      # offerer側のマッチしていない人を無くす
      for offerer in non_matched_offerers do
          accepter = non_matched_accepters[0]
          matching_result[offerer] = accepter
          matching_rate[offerer] = matching_rate.values.max
          non_matched_accepters.delete(accepter)
      end

      # accepter側のマッチをしていない人を無くす
      temp = DaAlgorithm.sort_offerers(matching_rate)
      result = DaAlgorithm.transform_dict_stracture(matching_result)
      i = 0
      j = temp.count
      while non_matched_accepters.count > 0 do
          accepter = non_matched_accepters[0]
          result[temp[i%j]].push(accepter)
          non_matched_accepters.delete(accepter)
          i += 1
      end

      return result
  end


  def self.main(pref_data,allow_alone)
    p("AAAAAAAAAAAAAAAAAAA")
    matching_result = DaAlgorithm.da_algorithm(pref_data)
    if allow_alone then
        result = DaAlgorithm.transform_dict_stracture(matching_result)
        for accepter in DaAlgorithm.get_non_matched_accepters(pref_data, matching_result) do
            result[accepter] = []
        end
        temp = {}
        result.each do |key, values|
            for v in values do
                temp[v] = [key] + values
                temp[v].delete(v)
            end
        end
        result = result.merge(temp)

    else
        result = DaAlgorithm.regroup(pref_data, matching_result)
        temp = {}
        result.each do |key, values|
            for v in values do
                temp[v] = [key] + values
                temp[v].delete(v)
            end
        end
        result = result.merge(temp)
    end

    return result
  end
end
