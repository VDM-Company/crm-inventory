-- =============================================================================
-- CRM / Inventory Dashboard — seed data
-- =============================================================================
-- Loads data equivalent to the current in-memory mocks in server/api/*.ts and
-- server/utils/*.ts, so a fresh Postgres database looks the same as the app
-- does today. Run schema.sql first.
--
--   psql "postgresql://USER:PASSWORD@HOST:PORT/DBNAME" -f database/schema.sql
--   psql "postgresql://USER:PASSWORD@HOST:PORT/DBNAME" -f database/seed.sql
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- USERS  (server/api/customers.ts)
-- -----------------------------------------------------------------------------
INSERT INTO users (name, email, avatar_url, status, location) VALUES
  ('Alex Smith',        'alex.smith@example.com',        'https://i.pravatar.cc/128?u=1',  'subscribed',   'New York, USA'),
  ('Jordan Brown',      'jordan.brown@example.com',      'https://i.pravatar.cc/128?u=2',  'unsubscribed', 'London, UK'),
  ('Taylor Green',      'taylor.green@example.com',      'https://i.pravatar.cc/128?u=3',  'bounced',      'Paris, France'),
  ('Morgan White',      'morgan.white@example.com',      'https://i.pravatar.cc/128?u=4',  'subscribed',   'Berlin, Germany'),
  ('Casey Gray',        'casey.gray@example.com',        'https://i.pravatar.cc/128?u=5',  'subscribed',   'Tokyo, Japan'),
  ('Jamie Johnson',     'jamie.johnson@example.com',     'https://i.pravatar.cc/128?u=6',  'subscribed',   'Sydney, Australia'),
  ('Riley Davis',       'riley.davis@example.com',       'https://i.pravatar.cc/128?u=7',  'subscribed',   'New York, USA'),
  ('Kelly Wilson',      'kelly.wilson@example.com',      'https://i.pravatar.cc/128?u=8',  'subscribed',   'London, UK'),
  ('Drew Moore',        'drew.moore@example.com',        'https://i.pravatar.cc/128?u=9',  'bounced',      'Paris, France'),
  ('Jordan Taylor',     'jordan.taylor@example.com',     'https://i.pravatar.cc/128?u=10', 'subscribed',   'Berlin, Germany'),
  ('Morgan Anderson',   'morgan.anderson@example.com',   'https://i.pravatar.cc/128?u=11', 'subscribed',   'Tokyo, Japan'),
  ('Casey Thomas',      'casey.thomas@example.com',      'https://i.pravatar.cc/128?u=12', 'unsubscribed', 'Sydney, Australia'),
  ('Jamie Jackson',     'jamie.jackson@example.com',     'https://i.pravatar.cc/128?u=13', 'unsubscribed', 'New York, USA'),
  ('Riley White',       'riley.white@example.com',       'https://i.pravatar.cc/128?u=14', 'unsubscribed', 'London, UK'),
  ('Kelly Harris',      'kelly.harris@example.com',      'https://i.pravatar.cc/128?u=15', 'subscribed',   'Paris, France'),
  ('Drew Martin',       'drew.martin@example.com',       'https://i.pravatar.cc/128?u=16', 'subscribed',   'Berlin, Germany'),
  ('Alex Thompson',     'alex.thompson@example.com',     'https://i.pravatar.cc/128?u=17', 'unsubscribed', 'Tokyo, Japan'),
  ('Jordan Garcia',     'jordan.garcia@example.com',     'https://i.pravatar.cc/128?u=18', 'subscribed',   'Sydney, Australia'),
  ('Taylor Rodriguez',  'taylor.rodriguez@example.com',  'https://i.pravatar.cc/128?u=19', 'bounced',      'New York, USA'),
  ('Morgan Lopez',      'morgan.lopez@example.com',      'https://i.pravatar.cc/128?u=20', 'subscribed',   'London, UK');

-- -----------------------------------------------------------------------------
-- MEMBERS  (server/api/members.ts)
-- -----------------------------------------------------------------------------
INSERT INTO members (name, username, role, avatar_url) VALUES
  ('Anthony Fu',         'antfu',           'member', 'https://ipx.nuxt.com/f_auto,s_192x192/gh_avatar/antfu'),
  ('Baptiste Leproux',   'larbish',         'member', 'https://ipx.nuxt.com/f_auto,s_192x192/gh_avatar/larbish'),
  ('Benjamin Canac',     'benjamincanac',   'owner',  'https://ipx.nuxt.com/f_auto,s_192x192/gh_avatar/benjamincanac'),
  ('Céline Dumerc',      'celinedumerc',    'member', 'https://ipx.nuxt.com/f_auto,s_192x192/gh_avatar/celinedumerc'),
  ('Daniel Roe',         'danielroe',       'member', 'https://ipx.nuxt.com/f_auto,s_192x192/gh_avatar/danielroe'),
  ('Farnabaz',           'farnabaz',        'member', 'https://ipx.nuxt.com/f_auto,s_192x192/gh_avatar/farnabaz'),
  ('Ferdinand Coumau',   'FerdinandCoumau', 'member', 'https://ipx.nuxt.com/f_auto,s_192x192/gh_avatar/FerdinandCoumau'),
  ('Hugo Richard',       'hugorcd',         'owner',  'https://ipx.nuxt.com/f_auto,s_192x192/gh_avatar/hugorcd'),
  ('Pooya Parsa',        'pi0',             'member', 'https://ipx.nuxt.com/f_auto,s_192x192/gh_avatar/pi0'),
  ('Sarah Moriceau',     'SarahM19',        'member', 'https://ipx.nuxt.com/f_auto,s_192x192/gh_avatar/SarahM19'),
  ('Sébastien Chopin',   'Atinux',          'owner',  'https://ipx.nuxt.com/f_auto,s_192x192/gh_avatar/atinux');

-- -----------------------------------------------------------------------------
-- MAILS  (server/api/mails.ts)
-- -----------------------------------------------------------------------------
INSERT INTO mails (unread, sender_name, sender_email, sender_avatar_url, subject, body, sent_at) VALUES
(false, 'Alex Smith', 'alex.smith@example.com', 'https://i.pravatar.cc/128?u=1',
 'Meeting Schedule: Q1 Marketing Strategy Review',
$body$Dear Team,

I hope this email finds you well. Just a quick reminder about our Q1 Marketing Strategy meeting scheduled for tomorrow at 10 AM EST in Conference Room A.

Agenda:
- Q4 Performance Review
- New Campaign Proposals
- Budget Allocation for Q2
- Team Resource Planning

Please come prepared with your department updates. I've attached the preliminary deck for your review.

Best regards,
Alex Smith
Senior Marketing Director
Tel: (555) 123-4567$body$,
 now()),

(true, 'Jordan Brown', 'jordan.brown@example.com', 'https://i.pravatar.cc/128?u=2',
 'RE: Project Phoenix - Sprint 3 Update',
$body$Hi team,

Quick update on Sprint 3 deliverables:

✅ User authentication module completed
🏗️ Payment integration at 80%
⏳ API documentation pending review

Key metrics:
- Code coverage: 94%
- Sprint velocity: 45 points
- Bug resolution rate: 98%

Please review the attached report for detailed analysis. Let's discuss any blockers in tomorrow's stand-up.

Regards,
Jordan

--
Jordan Brown
Lead Developer | Tech Solutions
Mobile: +1 (555) 234-5678$body$,
 now() - interval '7 minutes'),

(true, 'Taylor Green', 'taylor.green@example.com', 'https://i.pravatar.cc/128?u=3',
 'Lunch Plans',
$body$Hi there!

I was wondering if you'd like to grab lunch this Friday? There's this amazing new Mexican restaurant downtown called "La Casa" that I've been wanting to try. They're known for their authentic tacos and house-made guacamole.

Would 12:30 PM work for you? It would be great to catch up and discuss the upcoming team building event while we're there.

Let me know what you think!

Best,
Taylor$body$,
 now() - interval '3 hours'),

(false, 'Morgan White', 'morgan.white@example.com', 'https://i.pravatar.cc/128?u=4',
 'New Proposal: Project Horizon',
$body$Hi team,

I've just uploaded the comprehensive proposal for Project Horizon to our shared drive. The document includes:

• Detailed project objectives and success metrics
• Resource allocation and team structure
• Timeline with key milestones
• Budget breakdown
• Risk assessment and mitigation strategies

I'm particularly excited about our innovative approach to the user engagement component, which could set a new standard for our industry.

Could you please review and provide feedback by EOD Friday? I'd like to present this to the steering committee next week.

Thanks in advance,

Morgan White
Senior Project Manager
Tel: (555) 234-5678$body$,
 now() - interval '1 day'),

(false, 'Casey Gray', 'casey.gray@example.com', NULL,
 'Updated: San Francisco Conference Trip Itinerary',
$body$Dear [Name],

Please find your confirmed travel itinerary below:

FLIGHT DETAILS:
Outbound: AA 1234
Date: March 15, 2024
DEP: JFK 09:30 AM
ARR: SFO 12:45 PM

HOTEL:
Marriott San Francisco
Check-in: March 15
Check-out: March 18
Confirmation #: MR123456

SCHEDULE:
March 15 - Evening: Welcome Reception (6 PM)
March 16 - Conference Day 1 (9 AM - 5 PM)
March 17 - Conference Day 2 (9 AM - 4 PM)

Please let me know if you need any modifications.

Best regards,
Casey Gray
Travel Coordinator
Office: (555) 345-6789$body$,
 now() - interval '1 day'),

(false, 'Jamie Johnson', 'jamie.johnson@example.com', NULL,
 'Q1 2024 Financial Performance Review',
$body$Dear Leadership Team,

Please find attached our Q1 2024 financial analysis report. Key highlights:

PERFORMANCE METRICS:
• Revenue: $12.4M (+15% YoY)
• Operating Expenses: $8.2M (-3% vs. budget)
• Net Profit Margin: 18.5% (+2.5% vs. Q4 2023)

AREAS OF OPTIMIZATION:
1. Cloud infrastructure costs (+22% over budget)
2. Marketing spend efficiency (-8% ROI vs. target)
3. Office operational costs (+5% vs. forecast)

I've scheduled a detailed review for Thursday at 2 PM EST. Calendar invite to follow.

Best regards,
Jamie Johnson
Chief Financial Officer
Ext: 4567$body$,
 now() - interval '2 days'),

(false, 'Riley Davis', 'riley.davis@example.com', 'https://i.pravatar.cc/128?u=7',
 '[Mandatory] New DevOps Tools Training Session',
$body$Hello Development Team,

This is a reminder about next week's mandatory training session on our updated DevOps toolkit.

📅 Date: Tuesday, March 19
⏰ Time: 10:00 AM - 12:30 PM EST
📍 Location: Virtual (Zoom link below)

We'll be covering:
• GitLab CI/CD pipeline improvements
• Docker container optimization
• Kubernetes cluster management
• New monitoring tools integration

Prerequisites:
1. Install Docker Desktop 4.25
2. Update VS Code to latest version
3. Complete pre-training survey (link attached)

Zoom Link: https://zoom.us/j/123456789
Password: DevOps2024

--
Riley Davis
DevOps Lead
Technical Operations
M: (555) 777-8888$body$,
 now() - interval '2 days'),

(true, 'Kelly Wilson', 'kelly.wilson@example.com', 'https://i.pravatar.cc/128?u=8',
 '🎉 Happy Birthday!',
$body$Dear [Name],

On behalf of the entire team, wishing you a fantastic birthday! 🎂

We've organized a small celebration in the break room at 3 PM today. Cake and refreshments will be served!

Your dedication and positive energy make our workplace better every day. Here's to another great year ahead!

Best wishes,
Kelly & The HR Team

P.S. Don't forget to check your email for a special birthday surprise from the company! 🎁

--
Kelly Wilson
HR Director
Human Resources Department
Tel: (555) 999-0000$body$,
 now() - interval '2 days'),

(false, 'Drew Moore', 'drew.moore@example.com', NULL,
 'Website Redesign Feedback Request - Phase 2',
$body$Hi there,

We're entering Phase 2 of our website redesign project and would value your input on the latest iterations.

New Features Implementation:
1. Dynamic product catalog
2. Enhanced search functionality
3. Personalized user dashboard
4. Mobile-responsive navigation

Review Links:
• Staging Environment: https://staging.example.com
• Design Specs: [Figma Link]
• User Flow Documentation: [Confluence Link]

Please provide feedback by EOD Friday. Key areas to focus on:
- User experience
- Navigation flow
- Content hierarchy
- Mobile responsiveness

Your insights will be crucial for our final implementation decisions.

Thanks in advance,
Drew Moore
UX Design Lead
Product Design Team$body$,
 now() - interval '5 days'),

(false, 'Jordan Taylor', 'jordan.taylor@example.com', NULL,
 'Corporate Wellness Program - Membership Renewal',
$body$Dear Valued Member,

Your corporate wellness program membership is due for renewal on April 1st, 2024.

NEW AMENITIES:
✨ Expanded yoga studio
🏋️ State-of-the-art cardio equipment
🧘 Meditation room
👥 Additional group fitness classes

RENEWAL BENEFITS:
• 15% early bird discount
• 3 complimentary personal training sessions
• Free wellness assessment
• Access to new mobile app

To schedule a tour or discuss renewal options, please book a time here: [Booking Link]

Stay healthy!

Best regards,
Jordan Taylor
Corporate Wellness Coordinator
Downtown Fitness Center
Tel: (555) 123-7890$body$,
 now() - interval '5 days'),

(true, 'Morgan Anderson', 'morgan.anderson@example.com', NULL,
 'Important: Updates to Your Corporate Insurance Policy',
$body$Dear [Employee Name],

This email contains important information about changes to your corporate insurance coverage effective April 1, 2024.

KEY UPDATES:
1. Health Insurance
   • Reduced co-pay for specialist visits ($35 → $25)
   • Extended telehealth coverage
   • New mental health benefits

2. Dental Coverage
   • Increased annual maximum ($1,500 → $2,000)
   • Added orthodontic coverage for dependents

3. Vision Benefits
   • Enhanced frame allowance
   • New LASIK discount program

Please review the attached documentation carefully and complete the acknowledgment form by March 25th.

Questions? Join our virtual info session:
📅 March 20th, 2024
⏰ 11:00 AM EST
🔗 [Teams Link]

Regards,
Morgan Anderson
Benefits Coordinator
HR Department$body$,
 now() - interval '12 days'),

(false, 'Casey Thomas', 'casey.thomas@example.com', NULL,
 '📚 March Book Club Meeting: "The Great Gatsby"',
$body$Hello Book Lovers!

I hope you're enjoying F. Scott Fitzgerald's masterpiece! Our next meeting details:

📅 Thursday, March 21st
⏰ 5:30 PM - 7:00 PM
📍 Main Conference Room (or Zoom)

Discussion Topics:
1. Symbolism of the green light
2. The American Dream theme
3. Character development
4. Social commentary

Please bring your suggestions for April's book selection!

Refreshments will be provided 🍪

RSVP by replying to this email.

Happy reading!
Casey

--
Casey Thomas
Book Club Coordinator
Internal Culture Committee$body$,
 now() - interval '1 month'),

(false, 'Jamie Jackson', 'jamie.jackson@example.com', NULL,
 '🍳 Company Cookbook Project - Recipe Submission Reminder',
$body$Dear Colleagues,

Final call for our company cookbook project submissions!

Guidelines for Recipe Submission:
1. Include ingredients list with measurements
2. Step-by-step instructions
3. Cooking time and servings
4. Photo of the finished dish (optional)
5. Any cultural or personal significance

Submission Deadline: March 22nd, 2024

We already have some amazing entries:
• Sarah's Famous Chili
• Mike's Mediterranean Pasta
• Lisa's Vegan Brownies
• Tom's Family Paella

All proceeds from cookbook sales will support our local food bank.

Submit here: [Form Link]

Cooking together,
Jamie Jackson
Community Engagement Committee
Ext. 5432$body$,
 now() - interval '1 month'),

(false, 'Riley White', 'riley.white@example.com', NULL,
 '🧘‍♀️ Updated Corporate Wellness Schedule - Spring 2024',
$body$Dear Wellness Program Participants,

Our Spring 2024 wellness schedule is now available!

NEW CLASSES:
Monday:
• 7:30 AM - Morning Flow Yoga
• 12:15 PM - HIIT Express
• 5:30 PM - Meditation Basics

Wednesday:
• 8:00 AM - Power Vinyasa
• 12:00 PM - Desk Stretching
• 4:30 PM - Mindfulness Workshop

Friday:
• 7:45 AM - Gentle Yoga
• 12:30 PM - Stress Management
• 4:45 PM - Weekend Wind-Down

All classes available in-person and via Zoom.
Download our app to reserve your spot!

Namaste,
Riley White
Corporate Wellness Instructor
Wellness & Benefits Team$body$,
 now() - interval '1 month'),

(false, 'Kelly Harris', 'kelly.harris@example.com', NULL,
 '📚 Book Launch Event: "Digital Transformation in the Modern Age"',
$body$Dear [Name],

You're cordially invited to the launch of my new book, "Digital Transformation in the Modern Age: A Leadership Guide"

EVENT DETAILS:
📅 Date: April 15th, 2024
⏰ Time: 6:00 PM - 8:30 PM EST
📍 Grand Hotel Downtown
   123 Business Ave.

AGENDA:
6:00 PM - Welcome Reception
6:30 PM - Keynote Presentation
7:15 PM - Q&A Session
7:45 PM - Book Signing
8:00 PM - Networking

Light refreshments will be served.
Each attendee will receive a signed copy of the book.

RSVP by April 1st: [Event Link]

Looking forward to sharing this milestone with you!

Best regards,
Kelly Harris
Digital Strategy Consultant
Author, "Digital Transformation in the Modern Age"$body$,
 now() - interval '1 month'),

(false, 'Drew Martin', 'drew.martin@example.com', NULL,
 '🚀 TechCon 2024: Early Bird Registration Now Open',
$body$Dear Tech Enthusiasts,

Registration is now open for TechCon 2024: "Innovation at Scale"

CONFERENCE HIGHLIGHTS:
📅 May 15-17, 2024
📍 Tech Convention Center

KEYNOTE SPEAKERS:
• Sarah Johnson - CEO, Future Tech Inc.
• Dr. Michael Chang - AI Research Director
• Lisa Rodriguez - Cybersecurity Expert

TRACKS:
1. AI/ML Innovation
2. Cloud Architecture
3. DevSecOps
4. Digital Transformation
5. Emerging Technologies

EARLY BIRD PRICING (ends April 1):
Full Conference Pass: $899 (reg. $1,199)
Team Discount (5+): 15% off

Register here: [Registration Link]

Best regards,
Drew Martin
Conference Director
TechCon 2024$body$,
 now() - interval '1 month 4 days'),

(false, 'Alex Thompson', 'alex.thompson@example.com', NULL,
 '🎨 Modern Perspectives: Contemporary Art Exhibition',
$body$Hi there,

Hope you're well! I wanted to personally invite you to an extraordinary art exhibition this weekend.

"Modern Perspectives: Breaking Boundaries"
📅 Saturday & Sunday
⏰ 10 AM - 6 PM
📍 Metropolitan Art Gallery

FEATURED ARTISTS:
• Maria Chen - Mixed Media
• James Wright - Digital Art
• Sofia Patel - Installation
• Robert Kim - Photography

SPECIAL EVENTS:
• Artist Talk: Saturday, 2 PM
• Workshop: Sunday, 11 AM
• Wine Reception: Saturday, 5 PM

Would love to meet you there! Let me know if you'd like to go together.

Best,
Alex Thompson
Curator
Metropolitan Art Gallery
Tel: (555) 234-5678$body$,
 now() - interval '1 month 15 days'),

(false, 'Jordan Garcia', 'jordan.garcia@example.com', NULL,
 '🤝 Industry Networking Event: "Connect & Innovate 2024"',
$body$Dear Professional Network,

You're invited to our premier networking event!

EVENT DETAILS:
📅 March 28th, 2024
⏰ 6:00 PM - 9:00 PM
📍 Innovation Hub
   456 Enterprise Street

SPEAKERS:
• Mark Thompson - "Future of Work"
• Dr. Sarah Chen - "Innovation Trends"
• Robert Mills - "Digital Leadership"

SCHEDULE:
6:00 - Registration & Welcome
6:30 - Keynote Presentations
7:30 - Networking Session
8:30 - Panel Discussion

Complimentary hors d'oeuvres and beverages will be served.

RSVP Required: [Registration Link]

Best regards,
Jordan Garcia
Event Coordinator
Professional Networking Association$body$,
 now() - interval '1 month 18 days'),

(false, 'Taylor Rodriguez', 'taylor.rodriguez@example.com', NULL,
 '🌟 Community Service Day - Volunteer Opportunities',
$body$Dear Colleagues,

Join us for our annual Community Service Day!

EVENT DETAILS:
📅 Saturday, April 6th, 2024
⏰ 9:00 AM - 3:00 PM
📍 Multiple Locations

VOLUNTEER OPPORTUNITIES:
1. City Park Cleanup
   • Garden maintenance
   • Trail restoration
   • Playground repair

2. Food Bank
   • Sorting donations
   • Packing meals
   • Distribution

3. Animal Shelter
   • Dog walking
   • Facility cleaning
   • Social media support

All volunteers receive:
• Company volunteer t-shirt
• Lunch and refreshments
• Certificate of participation
• 8 hours community service credit

Sign up here: [Volunteer Portal]

Making a difference together,
Taylor Rodriguez
Community Outreach Coordinator
Corporate Social Responsibility Team$body$,
 now() - interval '1 month 25 days'),

(false, 'Morgan Lopez', 'morgan.lopez@example.com', NULL,
 '🚗 Vehicle Maintenance Reminder: 30,000 Mile Service',
$body$Dear Valued Customer,

Your vehicle is due for its 30,000-mile maintenance service.

RECOMMENDED SERVICES:
• Oil and filter change
• Tire rotation and alignment
• Brake system inspection
• Multi-point safety inspection
• Fluid level check and top-off
• Battery performance test

SERVICE CENTER DETAILS:
📍 Downtown Auto Care
   789 Service Road

☎️ (555) 987-6543

Available Appointments:
• Monday-Friday: 7:30 AM - 6:00 PM
• Saturday: 8:00 AM - 2:00 PM

Schedule online: [Booking Link]
or call our service desk directly.

Drive safely,
Morgan Lopez
Service Coordinator
Downtown Auto Care
Emergency: (555) 987-6544$body$,
 now() - interval '2 months');

-- -----------------------------------------------------------------------------
-- NOTIFICATIONS  (server/api/notifications.ts)
-- -----------------------------------------------------------------------------
INSERT INTO notifications (unread, sender_name, sender_email, sender_avatar_url, body, sent_at) VALUES
  (true,  'Jordan Brown',      'jordan.brown@example.com',    'https://i.pravatar.cc/128?u=2',  'sent you a message',                 now() - interval '7 minutes'),
  (false, 'Lindsay Walton',    NULL,                          NULL,                             'subscribed to your email list',      now() - interval '1 hour'),
  (true,  'Taylor Green',      'taylor.green@example.com',    'https://i.pravatar.cc/128?u=3',  'sent you a message',                 now() - interval '3 hours'),
  (false, 'Courtney Henry',    NULL,                          'https://i.pravatar.cc/128?u=4',  'added you to a project',             now() - interval '3 hours'),
  (false, 'Tom Cook',          NULL,                          'https://i.pravatar.cc/128?u=5',  'abandonned cart',                    now() - interval '7 hours'),
  (false, 'Casey Thomas',      NULL,                          'https://i.pravatar.cc/128?u=6',  'purchased your product',             now() - interval '1 day 3 hours'),
  (true,  'Kelly Wilson',      'kelly.wilson@example.com',    'https://i.pravatar.cc/128?u=8',  'sent you a message',                 now() - interval '2 days'),
  (false, 'Jamie Johnson',     'jamie.johnson@example.com',   'https://i.pravatar.cc/128?u=9',  'requested a refund',                 now() - interval '5 days 4 hours'),
  (true,  'Morgan Anderson',   'morgan.anderson@example.com', NULL,                             'sent you a message',                 now() - interval '6 days'),
  (false, 'Drew Moore',        NULL,                          NULL,                             'subscribed to your email list',      now() - interval '6 days'),
  (false, 'Riley Davis',       NULL,                          NULL,                             'abandonned cart',                    now() - interval '7 days'),
  (false, 'Jordan Taylor',     NULL,                          NULL,                             'subscribed to your email list',      now() - interval '9 days'),
  (false, 'Kelly Wilson',      'kelly.wilson@example.com',    'https://i.pravatar.cc/128?u=8',  'subscribed to your email list',      now() - interval '10 days'),
  (false, 'Jamie Johnson',     'jamie.johnson@example.com',   'https://i.pravatar.cc/128?u=9',  'subscribed to your email list',      now() - interval '11 days'),
  (false, 'Morgan Anderson',   NULL,                          NULL,                             'purchased your product',             now() - interval '12 days'),
  (false, 'Drew Moore',        NULL,                          'https://i.pravatar.cc/128?u=16', 'subscribed to your email list',      now() - interval '13 days'),
  (false, 'Riley Davis',       NULL,                          NULL,                             'subscribed to your email list',      now() - interval '14 days'),
  (false, 'Jordan Taylor',     NULL,                          NULL,                             'subscribed to your email list',      now() - interval '15 days'),
  (false, 'Kelly Wilson',      'kelly.wilson@example.com',    'https://i.pravatar.cc/128?u=8',  'subscribed to your email list',      now() - interval '16 days'),
  (false, 'Jamie Johnson',     'jamie.johnson@example.com',   'https://i.pravatar.cc/128?u=9',  'purchased your product',             now() - interval '17 days'),
  (false, 'Morgan Anderson',   NULL,                          NULL,                             'abandonned cart',                    now() - interval '17 days'),
  (false, 'Drew Moore',        NULL,                          NULL,                             'subscribed to your email list',      now() - interval '18 days'),
  (false, 'Riley Davis',       NULL,                          NULL,                             'subscribed to your email list',      now() - interval '19 days'),
  (false, 'Jordan Taylor',     NULL,                          'https://i.pravatar.cc/128?u=24', 'subscribed to your email list',      now() - interval '20 days'),
  (false, 'Kelly Wilson',      'kelly.wilson@example.com',    'https://i.pravatar.cc/128?u=8',  'subscribed to your email list',      now() - interval '20 days'),
  (false, 'Jamie Johnson',     'jamie.johnson@example.com',   'https://i.pravatar.cc/128?u=9',  'abandonned cart',                    now() - interval '21 days'),
  (false, 'Morgan Anderson',   NULL,                          NULL,                             'subscribed to your email list',      now() - interval '22 days');

-- -----------------------------------------------------------------------------
-- INVENTORY ITEMS  (server/api/inventory.ts — 48 generated rows)
-- -----------------------------------------------------------------------------
-- Reproduces the JS generator exactly:
--   sku      = (2415515616 + i) padded to 12 digits
--   location = locations[i % 9]
--   stock    = ((i * 37) % 190) + 10
--   status   = i % 9 === 0 ? 'inactive' : 'active'
--   product/category/trackedBy cycle through the 16-item blueprint below
WITH blueprint(idx, product_name, category, tracked_by) AS (
  VALUES
    (0,  'iPhone 14 Pro (Silver)',        'Devices', 'Unique Serial Number'),
    (1,  'Galaxy S23 Ultra',              'Devices', 'Unique Serial Number'),
    (2,  'iPad Air 5',                    'Devices', 'Unique Serial Number'),
    (3,  'AirPods Pro (2nd Gen)',         'Devices', 'Unique Serial Number'),
    (4,  'Pixel Watch 2',                 'Devices', 'Unique Serial Number'),
    (5,  'Docomo SIM Card',               'SIM',     'Batch Number'),
    (6,  '5G SIM Pack',                   'SIM',     'Batch Number'),
    (7,  'eSIM Activation Code',          'SIM',     'Unique Serial Number'),
    (8,  'Prepaid Data SIM',              'SIM',     'Batch Number'),
    (9,  'Branded Tote Bag',              'Gifts',   'Quantity Count'),
    (10, 'Gift Card ¥5,000',              'Gifts',   'Unique Serial Number'),
    (11, 'Welcome Kit Box',               'Gifts',   'Quantity Count'),
    (12, 'USB-C Cable (2m)',              'Supply',  'Quantity Count'),
    (13, 'Power Bank 10,000mAh',          'Supply',  'Quantity Count'),
    (14, 'Screen Protector',              'Supply',  'Quantity Count'),
    (15, 'Phone Case (Clear)',            'Supply',  'Quantity Count')
),
locations(idx, location) AS (
  VALUES
    (0, 'SIM Cards'), (1, 'Smartphones'), (2, 'Internet Plan'),
    (3, 'Laptops'),   (4, 'Cloud Storage'), (5, 'Wearables'),
    (6, 'Mobile Insurance'), (7, 'Accessories'), (8, 'System Update')
),
series AS (
  SELECT gs AS i FROM generate_series(0, 47) gs
)
INSERT INTO inventory_items (product_name, sku, location, stock, tracked_by, category, status)
SELECT
  b.product_name,
  lpad((2415515616 + s.i)::text, 12, '0'),
  l.location,
  ((s.i * 37) % 190) + 10,
  b.tracked_by,
  b.category::inventory_category,
  (CASE WHEN s.i % 9 = 0 THEN 'inactive' ELSE 'active' END)::inventory_status
FROM series s
JOIN blueprint b ON b.idx = s.i % 16
JOIN locations l ON l.idx = s.i % 9
ORDER BY s.i;

-- -----------------------------------------------------------------------------
-- PHYSICAL INVENTORY ITEMS  (server/api/physical-inventory.ts)
-- -----------------------------------------------------------------------------
INSERT INTO physical_inventory_items (product_name, sku, on_hand) VALUES
  ('Akari LED Panel 60x60',          'AKR-001', 100),
  ('Bamboo Desk Lamp',               'BDL-002', 75),
  ('Smart Wi-Fi Speaker',            'SWS-003', 150),
  ('Ergonomic Office Chair',         'EOC-004', 200),
  ('Wireless Charging Pad',          'WCP-005', 30),
  ('Adjustable Laptop Stand',        'ALS-006', 50),
  ('Noise-Canceling Headphones',     'NCH-007', 90),
  ('Portable Bluetooth Projector',   'PBP-008', 120),
  ('Digital Smart Thermostat',       'DST-009', 130),
  ('Compact Air Purifier',           'CAP-010', 60),
  ('LED Ring Light',                 'LRL-011', 110);

-- -----------------------------------------------------------------------------
-- DASHBOARD WIDGETS  (client-side mocks — see note in schema.sql)
-- -----------------------------------------------------------------------------
INSERT INTO low_stock_items (name, threshold, current_stock) VALUES
  ('iPhone 14 Pro (Silver)', 50,  8),
  ('Docomo SIM Card',        100, 12),
  ('USB-C Cable (2m)',       20,  4);

INSERT INTO incoming_stock_items (name, threshold, current_stock, expected_date, status) VALUES
  ('500 units - iPhone 15 PM',       50,  8,  '2024-10-24', 'in-transit'),
  ('2,000 units - 5G SIM Packs',     100, 12, '2024-10-24', 'processing'),
  ('100 units - iPad Air 5',         20,  4,  '2024-10-24', 'scheduled');

-- Illustrative sample rows only — HomeSales.vue currently generates 5 random
-- rows on every page load rather than reading persisted sales.
INSERT INTO sales (sold_at, status, customer_email, amount) VALUES
  (now() - interval '2 hours',  'paid',     'james.anderson@example.com', 483.00),
  (now() - interval '9 hours',  'paid',     'mia.white@example.com',      721.50),
  (now() - interval '1 day',    'refunded', 'william.brown@example.com',  152.00),
  (now() - interval '1 day 8 hours', 'failed', 'emma.davis@example.com',  310.75),
  (now() - interval '2 days',   'paid',     'ethan.harris@example.com',   899.00);

-- -----------------------------------------------------------------------------
-- CUSTOM FIELDS  (server/api/fields.ts)
-- -----------------------------------------------------------------------------
INSERT INTO custom_fields (label, field_type, field_location, section, required, visibility) VALUES
  ('Activation Code',  'Text',     'Product Activation', 'Add Product Quantity Modal', false, true),
  ('Batch Expiry',      'Date',    'Delivery',            'Add Delivery',               false, true),
  ('ICCID',             'Number',  'Product Activation', 'Add Product Quantity Modal', false, true),
  ('Product Category',  'Dropdown', 'Product Activation', 'Add Product Quantity Modal', false, true);
-- None of the current mock custom fields define conditionalVisibility, so
-- custom_field_conditions intentionally has no seed rows.

-- -----------------------------------------------------------------------------
-- PRODUCTS  (server/utils/productsData.ts)
-- -----------------------------------------------------------------------------
INSERT INTO products (name, reference, category, product_type, company, tracked_by, status, sku, notes, settings_category, platform, published, track_inventory) VALUES
  ('internet Wifi 10GB', '220041515125', 'WIFI',       'Bundle', 'VDM', 'Unique Serial Number', 'Active',   'WIFI-001', '', 'WIFI',              'SK', true,  true),
  ('SIM CARD 001',       '002415515617', 'Smartphones','Single', 'VDS', 'Unique Serial Number', 'Active',   'SIM-002', NULL, 'Smartphones',       'SK', true,  true),
  ('SIM CARD 002',       '002415515618', 'Tablets',    'Dual',   'VDM', 'Lot',                   'Inactive', 'SIM-003', NULL, 'Tablets',           'SK', false, false),
  ('SIM CARD 003',       '002415515619', 'SIM Cards',  'Single', 'VDS', 'Unique Serial Number', 'Active',   'SIM-004', NULL, 'Sim / Sim Cards',   'SK', true,  true),
  ('SIM CARD 004',       '002415515620', 'Smartphones','Dual',   'VDM', 'Lot',                   'Inactive', 'SIM-005', NULL, 'Smartphones',       'SK', false, true),
  ('SIM CARD 005',       '002415515621', 'Tablets',    'Single', 'VDS', 'Unique Serial Number', 'Active',   'SIM-006', NULL, 'Tablets',           'SK', true,  true),
  ('SIM CARD 006',       '002415515622', 'SIM Cards',  'Dual',   'VDM', 'Lot',                   'Inactive', 'SIM-007', NULL, 'Sim / Sim Cards',   'SK', false, false),
  ('SIM CARD 007',       '002415515623', 'Smartphones','Single', 'VDS', 'Unique Serial Number', 'Active',   'SIM-008', NULL, 'Smartphones',       'SK', true,  true),
  ('SIM CARD 008',       '002415515624', 'Tablets',    'Dual',   'VDM', 'Lot',                   'Inactive', 'SIM-009', NULL, 'Tablets',           'SK', false, true),
  ('SIM CARD 009',       '002415515625', 'SIM Cards',  'Single', 'VDS', 'Unique Serial Number', 'Active',   'SIM-010', NULL, 'Sim / Sim Cards',   'SK', true,  true);

-- ProductPricing[] — only product #1 ("internet Wifi 10GB") has pricing rows in the mock
INSERT INTO product_pricing (product_id, price_version, monthly_fee, initial_fee, status, status_since) VALUES
  ((SELECT id FROM products WHERE reference = '220041515125'), 'V.1', '¥20.000 JYP', '¥1000 JYP', 'Inactive', 'Since Apr 24, 2026'),
  ((SELECT id FROM products WHERE reference = '220041515125'), 'V.2', '¥20.000 JYP', '¥1000 JYP', 'Active',   'Since Apr 24, 2026');

-- ProductBundle — only product #1 is a bundle in the mock
INSERT INTO product_bundles (product_id, total_quantity) VALUES
  ((SELECT id FROM products WHERE reference = '220041515125'), 5);

INSERT INTO product_bundle_components (bundle_id, component_key, name, required, position) VALUES
  ((SELECT id FROM product_bundles WHERE product_id = (SELECT id FROM products WHERE reference = '220041515125')), 'device', 'Device Component',    false, 0),
  ((SELECT id FROM product_bundles WHERE product_id = (SELECT id FROM products WHERE reference = '220041515125')), 'sim',    'SIM Card Component',  true,  1);

INSERT INTO product_bundle_items (component_id, name, sku, quantity) VALUES
  ((SELECT id FROM product_bundle_components WHERE component_key = 'device'), 'Nec Device',    'nec_device_sku', 5),
  ((SELECT id FROM product_bundle_components WHERE component_key = 'device'), 'Nec Device',    'x4_device_sku',  6),
  ((SELECT id FROM product_bundle_components WHERE component_key = 'sim'),    'Docomo 1GB',    'd_1gb_device_sku', 2),
  ((SELECT id FROM product_bundle_components WHERE component_key = 'sim'),    'Softbank 1GB',  's_1gb_device_sku', 3);

-- ProductQuantityItem[]  (server/utils/productQuantitiesData.ts) — only product #1 has quantities in the mock
INSERT INTO product_quantity_items (product_id, location, imei, iccid, msn_number, activation_code, vendor, status) VALUES
  ((SELECT id FROM products WHERE reference = '220041515125'), 'WH/Stock', '002415515616', '245151616166', '081256677899', '099921566', 'VDM', 'Ready'),
  ((SELECT id FROM products WHERE reference = '220041515125'), 'WH/Stock', '003215517618', '345151617168', '091256677901', '199921568', 'VDN', 'Ready'),
  ((SELECT id FROM products WHERE reference = '220041515125'), 'WH/Stock', '004115519619', '445151618169', '101256677902', '299921569', 'VDO', 'Ready'),
  ((SELECT id FROM products WHERE reference = '220041515125'), 'WH/Stock', '005115520620', '545151619170', '111256677903', '399921570', 'VDM', 'Ready'),
  ((SELECT id FROM products WHERE reference = '220041515125'), 'WH/Stock', '006115521621', '645151620171', '121256677904', '499921571', 'VDN', 'Ready'),
  ((SELECT id FROM products WHERE reference = '220041515125'), 'WH/Stock', '007115522622', '745151621172', '131256677905', '599921572', 'VDO', 'Ready'),
  ((SELECT id FROM products WHERE reference = '220041515125'), 'WH/Stock', '008115523623', '845151622173', '141256677906', '699921573', 'VDM', 'Ready'),
  ((SELECT id FROM products WHERE reference = '220041515125'), 'WH/Stock', '009115524624', '945151623174', '151256677907', '799921574', 'VDN', 'Ready'),
  ((SELECT id FROM products WHERE reference = '220041515125'), 'WH/Stock', '010115525625', '105151624175', '161256677908', '899921575', 'VDO', 'Ready'),
  ((SELECT id FROM products WHERE reference = '220041515125'), 'WH/Stock', '011115526626', '115151625176', '171256677909', '999921576', 'VDM', 'Ready');

-- -----------------------------------------------------------------------------
-- DELIVERY ORDERS  (server/utils/deliveryOrdersData.ts)
-- -----------------------------------------------------------------------------
INSERT INTO delivery_orders (reference, destination, schedule_date, status, warehouse_ref, source_location, operation_type, shipping_policy, schedule_at, workflow_status) VALUES
  ('001-224-241', 'Partner/Customer', to_date('17-03-2026', 'DD-MM-YYYY'), 'Draft',       '#WH/OUT/2026/0042', 'WH/Stock', 'Delivery Orders', 'When products are ready',   '2026-03-20', 'Waiting'),
  ('003-456-789', 'Tokyo Central',    to_date('20-04-2026', 'DD-MM-YYYY'), 'Draft',       '#WH/OUT/2026/0043', 'WH/Stock', 'Delivery Orders', 'When products are ready',   NULL,         NULL),
  ('004-123-456', 'Osaka Branch',     to_date('22-05-2026', 'DD-MM-YYYY'), 'Draft',       '#WH/OUT/2026/0044', 'WH/Stock', 'Delivery Orders', 'As soon as possible',       NULL,         NULL),
  ('005-789-012', 'Kyoto District',   to_date('15-06-2026', 'DD-MM-YYYY'), 'Pending',     '#WH/OUT/2026/0045', 'WH/Stock', 'Delivery Orders', 'When products are ready',   NULL,         NULL),
  ('006-234-567', 'Nagoya Office',    to_date('28-07-2026', 'DD-MM-YYYY'), 'Draft',       '#WH/OUT/2026/0046', 'WH/Stock', 'Delivery Orders', 'When products are ready',   NULL,         NULL),
  ('007-890-123', 'Fukuoka Station',  to_date('30-08-2026', 'DD-MM-YYYY'), 'Pending',     '#WH/OUT/2026/0047', 'WH/Stock', 'Delivery Orders', 'When products are ready',   NULL,         NULL),
  ('008-345-678', 'Sapporo Hub',      to_date('10-09-2026', 'DD-MM-YYYY'), 'On Delivery', '#WH/OUT/2026/0048', 'WH/Stock', 'Delivery Orders', 'When products are ready',   NULL,         NULL),
  ('009-678-901', 'Hiroshima Base',   to_date('05-10-2026', 'DD-MM-YYYY'), 'Delivered',   '#WH/OUT/2026/0049', 'WH/Stock', 'Delivery Orders', 'When products are ready',   NULL,         NULL),
  ('010-234-890', 'Sendai Office',    to_date('25-11-2026', 'DD-MM-YYYY'), 'On Delivery', '#WH/OUT/2026/0050', 'WH/Stock', 'Delivery Orders', 'When products are ready',   NULL,         NULL),
  ('011-345-901', 'Kobe Branch',      to_date('12-12-2026', 'DD-MM-YYYY'), 'Delivered',   '#WH/OUT/2026/0051', 'WH/Stock', 'Delivery Orders', 'When products are ready',   NULL,         NULL);

-- Only delivery order #1 ('001-224-241') has products/quantityItems in the mock
INSERT INTO delivery_order_products (delivery_order_id, product_name, demand, product_category, product_status) VALUES
  ((SELECT id FROM delivery_orders WHERE reference = '001-224-241'), 'Docomo SIM CARD 50GB', 50, 'SIM Card', 'Ready');

INSERT INTO delivery_order_quantity_items (delivery_order_id, product_name, lot_serial, demand, quantity, stock) VALUES
  ((SELECT id FROM delivery_orders WHERE reference = '001-224-241'), 'Docomo SIM CARD 50GB', 'N/A', 50, 50, 120);

-- -----------------------------------------------------------------------------
-- RECEIPTS  (server/utils/receiptsData.ts)
-- -----------------------------------------------------------------------------
INSERT INTO receipts (reference, destination, schedule_date, status, warehouse_ref, source_location, operation_type, schedule_at, notes, workflow_status) VALUES
  ('001-224-241', 'Partner/Customer', to_date('17-03-2026', 'DD-MM-YYYY'), 'Draft',       '#WH/IN/2026/0042', 'WH/Stock', 'Receipts', '2026-03-20',
   'Receipt of the first batch of NX-7200 series routers for the Q2 network rollout. Ensure that the serial numbers are checked against PO-2026-0312. Coordinate with the QC team before the equipment is moved to the racks.',
   'Waiting'),
  ('002-334-512', 'Tokyo Warehouse',  to_date('20-04-2026', 'DD-MM-YYYY'), 'Draft',       '#WH/IN/2026/0043', 'WH/Stock', 'Receipts', NULL, NULL, NULL),
  ('003-445-623', 'Osaka Branch',     to_date('22-05-2026', 'DD-MM-YYYY'), 'Pending',     '#WH/IN/2026/0044', 'WH/Stock', 'Receipts', NULL, NULL, NULL),
  ('004-556-734', 'Kyoto District',   to_date('15-06-2026', 'DD-MM-YYYY'), 'Draft',       '#WH/IN/2026/0045', 'WH/Stock', 'Receipts', NULL, NULL, NULL),
  ('005-667-845', 'Nagoya Office',    to_date('28-07-2026', 'DD-MM-YYYY'), 'Pending',     '#WH/IN/2026/0046', 'WH/Stock', 'Receipts', NULL, NULL, NULL),
  ('006-778-956', 'Fukuoka Station',  to_date('30-08-2026', 'DD-MM-YYYY'), 'On Delivery', '#WH/IN/2026/0047', 'WH/Stock', 'Receipts', NULL, NULL, NULL),
  ('007-889-067', 'Sapporo Hub',      to_date('10-09-2026', 'DD-MM-YYYY'), 'On Delivery', '#WH/IN/2026/0048', 'WH/Stock', 'Receipts', NULL, NULL, NULL),
  ('008-990-178', 'Hiroshima Base',   to_date('05-10-2026', 'DD-MM-YYYY'), 'Delivered',   '#WH/IN/2026/0049', 'WH/Stock', 'Receipts', NULL, NULL, NULL),
  ('009-101-289', 'Sendai Office',    to_date('25-11-2026', 'DD-MM-YYYY'), 'On Delivery', '#WH/IN/2026/0050', 'WH/Stock', 'Receipts', NULL, NULL, NULL),
  ('010-212-390', 'Kobe Branch',      to_date('12-12-2026', 'DD-MM-YYYY'), 'Delivered',   '#WH/IN/2026/0051', 'WH/Stock', 'Receipts', NULL, NULL, NULL);

-- Only receipt #1 ('001-224-241') has products/quantityItems in the mock
INSERT INTO receipt_products (receipt_id, product_name, demand, product_category, product_status) VALUES
  ((SELECT id FROM receipts WHERE reference = '001-224-241'), 'Docomo SIM CARD 50GB', 50, 'SIM Card', 'Ready');

INSERT INTO receipt_quantity_items (receipt_id, product_name, lot_serial, demand, quantity, stock) VALUES
  ((SELECT id FROM receipts WHERE reference = '001-224-241'), 'Docomo SIM CARD 50GB', 'N/A', 50, 50, 120);

COMMIT;
