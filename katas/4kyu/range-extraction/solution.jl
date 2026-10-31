module Solution
  export rangeextraction

  function rangeextraction(list)
    isempty(list) && return ""
    parts = String[]
    n = length(list)
    i = 1
    while i <= n
      j = i
      while j < n && list[j + 1] == list[j] + 1
        j += 1
      end
      if j - i >= 2
        push!(parts, "$(list[i])-$(list[j])")
      elseif j - i == 1
        push!(parts, string(list[i]), string(list[j]))
      else
        push!(parts, string(list[i]))
      end
      i = j + 1
    end
    join(parts, ",")
  end
end
