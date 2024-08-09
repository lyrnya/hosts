#!/bin/env fish
# 下载去广告hosts合并并去重

set r raw
set l list
set hs hosts

# 下载原始 hosts 到 raw
rm -f $r
for i in (grep ^http rule)
  curl -s "$i" >> $r
  echo $i
end

# 合并整理的 host
cat */$hs >> $r
echo -n "只合并行数：" && wc -l $r

# 转换换行符
dos2unix *
dos2unix */*

# 准备纯域名 host
cp $r $l

# 删除空白符和 # 及后
sed -i "s/\s\|#.*//g" $l

# 保留 127.0.0.1、0.0.0.0 开头的行，
sed -i "/^\(127.0.0.1\|0.0.0.0\)/!d" $l

# 删除127.0.0.1、0.0.0.0
sed -ni "s/^\(127.0.0.1\|0.0.0.0\)//p" $l

# 删除含有特殊字符的行
sed -i '/\(。\|\/\|@\|*\|\:\)/d' $l

# 删除没有.的行
sed -i '/\./!d' $l

# 保留 0-9a-zA-Z 开头的行
sed -i "/^[0-9a-zA-Z]/!d" $l
echo -n "清洗后域名数：" && wc -l $l

# 排序去重 获得标准去重版 host
sort -u $l -o $l

echo -n "去重后（去除误杀前）域名数：" && wc -l $l

# 使用声明
set statement "# "(date '+%Y-%m-%d %T')"\n\n127.0.0.1 localhost\n::1 localhost\n"

# 获得标准版 hosts
cp $l $hs
sed -i "s/^/0.0.0.0 /g" $hs
sed -i "1 i $statement" $hs
