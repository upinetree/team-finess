require("TTR")

# postscript('hoge.eps')
# plot(any)
# dev.off()

par(ps = 16, bg = 'white', mar=c(4, 4, 4, 4))

par(mfrow=c(1, 1))

wdays <- c("Sun", "Mon", "Tue", "Wed", "Tur", "Fri", "Sut")
barplot(table(comments$wday), name = wdays, col = 'orange', main = "comment count on each week days")

readline()
par(mfrow=c(1, 1))

barplot(table(comments$hour), col = 'orange', main = "comment count at each hours (JST)")

readline()
par(mfrow=c(1, 1))

sma.comments.date = SMA(table(comments$date), n = 5)
barplot(sma.comments.date, name = names(table(comments$date)), main = 'comment count (moving average 5)')

# readline()
# par(mfrow=c(2, 1))

# plot(pulls$created_at, SMA(na.approx(pulls$hours_until_close), n = 30), type='b', main='hours until close pull request\nmoving average (n = 30)')
# plot(pulls$created_at, SMA(na.approx(pulls$hours_until_first_comment), n = 30), type='b', main='hours until the first comment\nmoving average (n = 30)')

readline()
par(mfrow=c(1, 1))

plot(pulls$number, pulls$hours_until_close, type = 'h', main = "hours until close pull request")
lm_results.hours_until_close <- lm(as.integer(pulls$hours_until_close) ~ pulls$number)
abline(lm_results.hours_until_close, lwd=1, col="blue")

readline()
par(mfrow=c(1, 1))

plot(pulls$number, pulls$hours_until_first_comment, type='h', main="hours until the first comment")
lm_results.hours_until_first_comment <- lm(as.integer(pulls$hours_until_first_comment) ~ pulls$number)
abline(lm_results.hours_until_first_comment, lwd=1, col="blue")

readline()
par(mfrow=c(3, 1))

hist(pulls$comment_count, breaks = 'scott', col = 'orange', main = 'frequency of comment counts')
hist(subset(pulls$hours_until_first_comment, 0 <= pulls$hours_until_first_comment), breaks = 'scott', col = 'orange', main = 'frequency of hours until first comment')
hist(as.integer(subset(pulls$hours_until_close, pulls$hours_until_close < 50)), breaks = 'scott', col = 'orange', main = 'frequency of hours until close')

# readline()
# par(mfrow=c(1, 1))

# 相関チェック
# pairs(~ number + comment_count + hours_until_first_comment + hours_until_close, data = pulls, panel = panel.smooth, subset = hours_until_first_comment > 0)

par(mfrow=c(1, 1))

