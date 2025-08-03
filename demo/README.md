# Rails Page Builder - Live Demo Setup

## Quick Demo URL Setup

To test the Rails Page Builder gem, you can deploy it to any of these platforms:

### Option 1: Heroku (Recommended)
```bash
# 1. Install Heroku CLI and login
heroku login

# 2. Create a new Heroku app
heroku create rails-page-builder-demo

# 3. Set environment variables
heroku config:set RAILS_ENV=production
heroku config:set SECRET_KEY_BASE=$(rails secret)

# 4. Deploy
git push heroku main

# 5. Run migrations
heroku run rails db:migrate

# Your demo will be available at:
# https://rails-page-builder-demo.herokuapp.com
```

### Option 2: Railway
```bash
# 1. Install Railway CLI
npm install -g @railway/cli

# 2. Login and deploy
railway login
railway init
railway up

# Your demo will be available at:
# https://your-app.railway.app
```

### Option 3: Render
```bash
# 1. Connect your GitHub repo to Render
# 2. Create a new Web Service
# 3. Set build command: bundle install && rails assets:precompile
# 4. Set start command: rails server -p $PORT -e $RAILS_ENV

# Your demo will be available at:
# https://your-app.onrender.com
```

### Option 4: Local Development Server
```bash
# For local testing
rails server -p 3000

# Access at: http://localhost:3000
```

## Demo Features Available

When you deploy, users can access:

- `/` - Landing page with gem introduction
- `/demo` - Interactive page builder demo
- `/examples` - Pre-built page examples
- `/docs` - Documentation and API reference

## Demo Account Setup

The demo includes these test accounts:

- **Admin**: admin@demo.com / password123
- **Editor**: editor@demo.com / password123  
- **Viewer**: viewer@demo.com / password123

## Custom Domain Setup

To use a custom domain like `demo.railspagebuilder.com`:

1. **Purchase domain** from your preferred registrar
2. **Add CNAME record**: `demo.railspagebuilder.com` → `your-app.herokuapp.com`
3. **Configure SSL** through your hosting platform
4. **Update environment variables** with your domain

## Environment Configuration

Create a `.env` file for production:

```env
# Domain
DOMAIN_NAME=demo.railspagebuilder.com

# Database
DATABASE_URL=postgresql://user:pass@host:port/dbname

# Redis (for caching and real-time features)
REDIS_URL=redis://localhost:6379

# File storage (AWS S3 recommended)
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_REGION=us-east-1
AWS_S3_BUCKET=page-builder-assets

# Analytics
ANALYTICS_ENABLED=true

# Security
ALLOWED_HOSTS=demo.railspagebuilder.com,localhost

# Rate limiting
RATE_LIMIT_ENABLED=true
```

## Monitoring and Analytics

The demo includes built-in analytics. To view:

- Visit `/admin/analytics` with admin credentials
- Real-time metrics at `/admin/live-metrics`
- Performance dashboard at `/admin/performance`

## Demo Data

The demo automatically seeds with:

- 10 sample pages in multiple languages
- 30+ block examples
- 8 professional templates
- Sample user accounts and permissions

## Support

For demo issues or questions:

- GitHub Issues: https://github.com/hadivarp/rails-page-builder/issues
- Email: h.varposhti@roundtableapps.com
- Documentation: https://docs.railspagebuilder.com