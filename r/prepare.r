#-----------------------------
# 取得
#-----------------------------
data_path <- 'data/'
repo <- 'rails.rails'

comments_filename <- paste(data_path, repo, '.comments.csv', sep = '')
pulls_filename <- paste(data_path, repo, '.pulls.csv', sep = '')

# csvから取得
comments <- read.csv(comments_filename, header=FALSE)
names(comments) <- c('id', 'type', 'body', 'user', 'created_at', 'pr_number', 'target')

pulls <- read.csv(pulls_filename, header=FALSE)
names(pulls) <- c('number', 'state', 'title', 'user', 'body', 'created_at', 'closed_at')

str(comments, vec.len = 1)
str(pulls, vec.len = 1)

#-----------------------------
# 加工、整形
#-----------------------------
comments <- within(comments, {
  # 日にち
  created_at <- as.POSIXlt(strptime(created_at, format="%Y-%m-%d %H:%M:%S") + 60 * 60 * 9)
  date <- as.Date(created_at)
  hour <- created_at$hour
  wday <- created_at$wday
})
comments <- subset(comments, select = -c(id, body))[order(comments$created_at), ]

pulls <- within(pulls, {
  # 日にち
  created_at <- as.POSIXlt(strptime(created_at, format="%Y-%m-%d %H:%M:%S")) + 60 * 60 * 9
  closed_at  <- as.POSIXlt(strptime(closed_at , format="%Y-%m-%d %H:%M:%S")) + 60 * 60 * 9
  hours_until_close <- difftime(closed_at, created_at, units = 'hours')

  # コメントに関する指標
  related_comments = list()
  hours_until_first_comment = array()
  comment_count = array()
  # comment_count_per_person

  for (i in 1:nrow(pulls)) {
    related_comments[[i]] <- comments[comments$pr_number == number[i],]
    comment_count[i] <- nrow(related_comments[[i]])
    if (nrow(related_comments[[i]]) != 0) {
      hours_until_first_comment[i] <- difftime(min(related_comments[[i]]$created_at), created_at[i], units = 'hours')
      if (hours_until_first_comment[i] < 0) {
        print(paste("rouneded", hours_until_first_comment[i], "(", i, ")", "to zero"))
        hours_until_first_comment[i] <- 0
      }
    }
  }
})
pulls <- subset(pulls, select = -c(i, state, title, body))[order(pulls$number), ]

