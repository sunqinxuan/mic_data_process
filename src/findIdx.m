function idx=findIdx(time_seq, time)

[~, idx] = min(abs(time_seq - time)); % 找到最接近a的元素的索引
