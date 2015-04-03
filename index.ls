require! {
  \koa.io : koa
  \koa-router : Router
  \koa-static : serve
  \koa-jade : jade
  url
}

app = koa!
router = Router!

require! \redis

redisConfFromEnv = process.env.REDIS_URL or process.env.REDISTOGO_URL or process.env.REDISCLOUD_URL
redisConf = if redisConfFromEnv
  url.parse redisConfFromEnv
else
  console.log '$REDIS_URL, $REDISTOGO_URL, $REDISCLOUD_URL not specified; falling back to redis://localhost:6379'
  url.parse \redis://localhost:6379

redisClient = redis.createClient redisConf.port, redisConf.hostname
if redisConf.auth then redisClient.auth redisConf.auth.split(\:)[1]

app.use serve \build
app.use jade.middleware do
  viewPath: "#{__dirname}/views"

router.get \/, ->*
  yield @render \index

app.use router.routes!

port = process.env.PORT or 3000
app.listen port
console.log "listening on #{port}"
