# Detection Reference

JavaScript snippets for identifying website technology stacks via Playwriter. Each section includes globals, script patterns, network patterns, and evidence format.

Run these inside `page.evaluate()` or as direct Playwriter code.

---

## Platform Detection

```js
const platform = {};

// Shopify
if (window.Shopify) {
  platform.name = 'Shopify';
  platform.tier = window.Shopify.theme ? 'Shopify' : 'Shopify';
  if (document.querySelector('meta[name="shopify-checkout-api-token"]')) platform.tier = 'Shopify Plus';
  platform.evidence = ['window.Shopify present'];
  if (window.Shopify.shop) platform.evidence.push(`shop: ${window.Shopify.shop}`);
}

// Salesforce Commerce Cloud (Demandware)
if (window.dw || document.querySelector('meta[name="generator"][content*="Demandware"]') || document.querySelector('script[src*="demandware"]')) {
  platform.name = 'Salesforce Commerce Cloud';
  platform.evidence = [];
  if (window.dw) platform.evidence.push('window.dw present');
  if (document.querySelector('script[src*="demandware"]')) platform.evidence.push('demandware script sources');
  // Check for SFRA vs SiteGenesis
  if (document.querySelector('script[src*="/cartridges/"]')) platform.evidence.push('cartridge-based architecture');
}

// Magento / Adobe Commerce
if (window.require && window.require.s && window.require.s.contexts && window.require.s.contexts._.config) {
  platform.name = 'Magento / Adobe Commerce';
  platform.evidence = ['RequireJS with Magento config detected'];
}
if (document.querySelector('script[src*="mage/"]') || document.querySelector('script[src*="Magento_"]')) {
  platform.name = 'Magento / Adobe Commerce';
  platform.evidence = platform.evidence || [];
  platform.evidence.push('Magento script paths detected');
}

// BigCommerce
if (window.BCData || document.querySelector('script[src*="bigcommerce.com"]')) {
  platform.name = 'BigCommerce';
  platform.evidence = [];
  if (window.BCData) platform.evidence.push('window.BCData present');
}

// WooCommerce
if (document.querySelector('meta[name="generator"][content*="WooCommerce"]') || window.wc_add_to_cart_params) {
  platform.name = 'WooCommerce';
  platform.evidence = [];
  if (window.wc_add_to_cart_params) platform.evidence.push('wc_add_to_cart_params present');
  if (document.querySelector('link[href*="woocommerce"]')) platform.evidence.push('WooCommerce CSS loaded');
}

// WordPress (non-WooCommerce)
if (!platform.name && (document.querySelector('meta[name="generator"][content*="WordPress"]') || window.wp)) {
  platform.name = 'WordPress';
  platform.evidence = [];
  if (window.wp) platform.evidence.push('window.wp present');
}

// Nuxt.js
if (window.__NUXT__) {
  platform.framework = 'Nuxt.js';
  platform.evidence = platform.evidence || [];
  platform.evidence.push('window.__NUXT__ present');
}

// Next.js
if (window.__NEXT_DATA__ || document.querySelector('#__next')) {
  platform.framework = 'Next.js';
  platform.evidence = platform.evidence || [];
  if (window.__NEXT_DATA__) platform.evidence.push('window.__NEXT_DATA__ present');
  if (document.querySelector('#__next')) platform.evidence.push('#__next container found');
}

// Vue Storefront
if (window.__VSF_STATE__ || document.querySelector('[data-server-rendered="true"]')) {
  platform.framework = 'Vue Storefront';
  platform.evidence = platform.evidence || [];
  platform.evidence.push('VSF state or SSR markers detected');
}

// Commercetools
if (document.querySelector('script[src*="commercetools"]') || document.querySelector('meta[content*="commercetools"]')) {
  platform.name = 'Commercetools';
  platform.evidence = ['commercetools references in page'];
}

// Squarespace
if (window.Static && window.Static.SQUARESPACE_CONTEXT) {
  platform.name = 'Squarespace';
  platform.evidence = ['window.Static.SQUARESPACE_CONTEXT present'];
}

// Wix
if (window.wixBiSession || document.querySelector('meta[name="generator"][content*="Wix"]')) {
  platform.name = 'Wix';
  platform.evidence = ['Wix markers detected'];
}

// SAP Commerce Cloud (Hybris)
if (window.ACC || document.querySelector('script[src*="/_ui/"]')) {
  platform.name = 'SAP Commerce Cloud (Hybris)';
  platform.evidence = [];
  if (window.ACC) platform.evidence.push('window.ACC present (Accelerator storefront)');
  const uiScripts = document.querySelectorAll('script[src*="/_ui/"]');
  if (uiScripts.length) platform.evidence.push(`${uiScripts.length} scripts from /_ui/ paths`);
  if (document.querySelector('script[src*="/_ui/addons/smarteditaddon"]')) platform.evidence.push('SmartEdit addon detected');
  if (document.querySelector('.yCmsContentSlot')) platform.evidence.push('yCmsContentSlot CMS markers');
  // Check cookies for Hybris session
  if (document.cookie.includes('JSESSIONID')) platform.evidence.push('JSESSIONID cookie (Java-based)');
}

console.log(JSON.stringify(platform));
```

### Asset URL Patterns

| Platform | Pattern |
|----------|---------|
| Shopify | `cdn.shopify.com/s/files/` |
| SFCC | `/on/demandware.static/`, `/dw/image/` |
| Magento | `/static/version*/frontend/` |
| BigCommerce | `*.bigcommerce.com/` |
| WooCommerce | `/wp-content/plugins/woocommerce/` |
| SAP Hybris | `/_ui/desktop/`, `/_ui/shared/`, `/_ui/addons/` |

---

## Search Provider Detection

### Globals Check

```js
const search = {};

// Algolia
if (window.algoliasearch || window.aa || document.querySelector('script[src*="algolia"]')) {
  search.provider = 'Algolia';
  search.evidence = [];
  if (window.algoliasearch) search.evidence.push('window.algoliasearch present');
  if (window.aa) search.evidence.push('Algolia analytics (aa) loaded');
  if (document.querySelector('[class*="ais-"]')) search.evidence.push('InstantSearch widgets in DOM');
}

// Searchspring
if (window.SearchSpring || document.querySelector('script[src*="searchspring"]')) {
  search.provider = 'Searchspring';
  search.evidence = [];
  if (window.SearchSpring) search.evidence.push('window.SearchSpring present');
}

// Constructor.io
if (window.ConstructorioClient || document.querySelector('script[src*="constructor.io"]')) {
  search.provider = 'Constructor.io';
  search.evidence = [];
  if (window.ConstructorioClient) search.evidence.push('ConstructorioClient present');
}

// Bloomreach
if (window.BrTrk || document.querySelector('script[src*="brcdn.com"]')) {
  search.provider = 'Bloomreach';
  search.evidence = [];
  if (window.BrTrk) search.evidence.push('window.BrTrk present');
}

// Klevu
if (window.klevu || document.querySelector('script[src*="klevu"]')) {
  search.provider = 'Klevu';
  search.evidence = [];
  if (window.klevu) search.evidence.push('window.klevu present');
}

// Coveo
if (window.Coveo || document.querySelector('script[src*="coveo"]')) {
  search.provider = 'Coveo';
  search.evidence = [];
  if (window.Coveo) search.evidence.push('window.Coveo present');
}

// Elasticsearch (direct)
if (document.querySelector('script[src*="elastic"]')) {
  search.provider = 'Elasticsearch';
  search.evidence = ['Elasticsearch scripts detected'];
}

// Typesense
if (window.typesense || document.querySelector('script[src*="typesense"]')) {
  search.provider = 'Typesense';
  search.evidence = ['Typesense detected'];
}

// Lucidworks / Fusion
if (window.defined && window.defined.lwFusion) {
  search.provider = 'Lucidworks Fusion';
  search.evidence = ['Fusion globals detected'];
}

// GroupBy
if (window.GroupByTracker || document.querySelector('script[src*="groupbycloud"]')) {
  search.provider = 'GroupBy';
  search.evidence = ['GroupBy detected'];
}

console.log(JSON.stringify(search));
```

### Network Request Patterns

Intercept XHR/fetch and match these URL patterns:

| Provider | URL Pattern |
|----------|-------------|
| Algolia | `*.algolianet.com`, `*.algolia.net` |
| Searchspring | `*.searchspring.net` |
| Constructor.io | `ac.cnstrc.com`, `quizzify.constructor.io` |
| Bloomreach | `*.brcdn.com`, `core.dxpapi.com` |
| Klevu | `*.ksearchnet.com` |
| Coveo | `*.cloud.coveo.com` |
| GroupBy | `*.groupbycloud.com` |
| Lucidworks | `*.lucidworks.com` |
| Loop54 | `*.54proxy.com` |
| Nosto | `*.nosto.com` |

---

## Recommendation / Personalization Detection

```js
const recs = {};

// Nosto
if (window.nostojs || window.nosto || document.querySelector('script[src*="nosto"]') || document.querySelector('[class*="nosto"]')) {
  recs.provider = 'Nosto';
  recs.evidence = [];
  if (window.nostojs) recs.evidence.push('window.nostojs present');
  if (document.querySelector('div.nosto_element, [class*="nosto"]')) recs.evidence.push('Nosto elements in DOM');
}

// Dynamic Yield
if (window.DY || window.DYO || document.querySelector('script[src*="dynamicyield"]')) {
  recs.provider = 'Dynamic Yield';
  recs.evidence = [];
  if (window.DY) recs.evidence.push('window.DY present');
}

// Monetate
if (window.monetate || document.querySelector('script[src*="monetate"]')) {
  recs.provider = 'Monetate';
  recs.evidence = [];
  if (window.monetate) recs.evidence.push('window.monetate present');
}

// RichRelevance
if (window.RR || window.rr_flush || document.querySelector('script[src*="richrelevance"]')) {
  recs.provider = 'RichRelevance';
  recs.evidence = [];
  if (window.RR) recs.evidence.push('window.RR present');
}

// Certona (now Kibo)
if (window.certona || document.querySelector('script[src*="certona"]')) {
  recs.provider = 'Certona';
  recs.evidence = ['certona detected'];
}

// Barilliance
if (window.brl || document.querySelector('script[src*="barilliance"]')) {
  recs.provider = 'Barilliance';
  recs.evidence = ['barilliance detected'];
}

// Bloomreach (recommendations)
if (window.BrTrk && document.querySelector('[data-br-widget]')) {
  recs.provider = 'Bloomreach';
  recs.evidence = ['BrTrk present with recommendation widgets'];
}

// Algolia Recommend
if (document.querySelector('[class*="aai-"]') || window.__algoliaRecommend) {
  recs.provider = 'Algolia Recommend';
  recs.evidence = ['Algolia Recommend widgets detected'];
}

// Constructor.io Recommendations
if (document.querySelector('[data-cnstrc-recommendations]')) {
  recs.provider = 'Constructor.io';
  recs.evidence = ['Constructor recommendation widgets in DOM'];
}

console.log(JSON.stringify(recs));
```

---

## A/B Testing Detection

```js
const ab = {};

// Optimizely
if (window.optimizely) {
  ab.provider = 'Optimizely';
  ab.evidence = ['window.optimizely present'];
  if (window.optimizely.get) ab.evidence.push('Optimizely Web SDK');
}

// Google Optimize (sunset but may still appear)
if (window.google_optimize || document.querySelector('script[src*="optimize.google"]')) {
  ab.provider = 'Google Optimize';
  ab.evidence = ['Google Optimize detected'];
}

// VWO (Visual Website Optimizer)
if (window._vwo_code || window.VWO || document.querySelector('script[src*="visualwebsiteoptimizer"]')) {
  ab.provider = 'VWO';
  ab.evidence = [];
  if (window._vwo_code) ab.evidence.push('window._vwo_code present');
  if (window.VWO) ab.evidence.push('window.VWO present');
}

// AB Tasty
if (window.ABTasty || document.querySelector('script[src*="abtasty"]')) {
  ab.provider = 'AB Tasty';
  ab.evidence = [];
  if (window.ABTasty) ab.evidence.push('window.ABTasty present');
}

// Dynamic Yield (also does A/B)
if (window.DY && window.DY.ServerUtil) {
  ab.provider = ab.provider || 'Dynamic Yield';
  ab.evidence = ab.evidence || [];
  ab.evidence.push('DY.ServerUtil (A/B module) present');
}

// LaunchDarkly
if (window.ldclient || document.querySelector('script[src*="launchdarkly"]')) {
  ab.provider = 'LaunchDarkly';
  ab.evidence = ['LaunchDarkly SDK detected'];
}

// Kameleoon
if (window.Kameleoon || document.querySelector('script[src*="kameleoon"]')) {
  ab.provider = 'Kameleoon';
  ab.evidence = ['Kameleoon detected'];
}

// Convert
if (window.convert || document.querySelector('script[src*="convert.com"]')) {
  ab.provider = 'Convert';
  ab.evidence = ['Convert.com detected'];
}

// Statsig
if (window.statsig || document.querySelector('script[src*="statsig"]')) {
  ab.provider = 'Statsig';
  ab.evidence = ['Statsig detected'];
}

console.log(JSON.stringify(ab));
```

---

## Analytics & Tracking Detection

```js
const analytics = [];

// Google Analytics / GA4
if (window.gtag || window.ga || window.google_tag_manager) {
  const entry = { provider: 'Google Analytics', evidence: [] };
  if (window.gtag) entry.evidence.push('gtag() present');
  if (window.ga) entry.evidence.push('ga() present (Universal Analytics)');
  if (window.dataLayer) entry.evidence.push(`dataLayer has ${window.dataLayer.length} entries`);
  analytics.push(entry);
}

// Google Tag Manager
if (window.google_tag_manager || document.querySelector('script[src*="googletagmanager"]')) {
  const containers = document.querySelectorAll('script[src*="googletagmanager.com/gtm.js"]');
  analytics.push({
    provider: 'Google Tag Manager',
    evidence: [`${containers.length} GTM container(s) found`]
  });
}

// Facebook Pixel
if (window.fbq || document.querySelector('script[src*="connect.facebook.net"]')) {
  analytics.push({ provider: 'Facebook Pixel', evidence: ['fbq() present'] });
}

// TikTok Pixel
if (window.ttq || document.querySelector('script[src*="analytics.tiktok.com"]')) {
  analytics.push({ provider: 'TikTok Pixel', evidence: ['ttq present'] });
}

// Pinterest Tag
if (window.pintrk || document.querySelector('script[src*="pintrk"]')) {
  analytics.push({ provider: 'Pinterest Tag', evidence: ['pintrk present'] });
}

// Segment
if (window.analytics && window.analytics.identify) {
  analytics.push({ provider: 'Segment', evidence: ['Segment analytics.js loaded'] });
}

// Hotjar
if (window.hj || document.querySelector('script[src*="hotjar"]')) {
  analytics.push({ provider: 'Hotjar', evidence: ['Hotjar detected'] });
}

// FullStory
if (window.FS || document.querySelector('script[src*="fullstory"]')) {
  analytics.push({ provider: 'FullStory', evidence: ['FullStory detected'] });
}

// Heap
if (window.heap || document.querySelector('script[src*="heap-analytics"]')) {
  analytics.push({ provider: 'Heap', evidence: ['Heap detected'] });
}

// Amplitude
if (window.amplitude || document.querySelector('script[src*="amplitude"]')) {
  analytics.push({ provider: 'Amplitude', evidence: ['Amplitude detected'] });
}

// Mixpanel
if (window.mixpanel || document.querySelector('script[src*="mixpanel"]')) {
  analytics.push({ provider: 'Mixpanel', evidence: ['Mixpanel detected'] });
}

// Adobe Analytics / Omniture
if (window.s_gi || window.AppMeasurement || document.querySelector('script[src*="omtrdc"]')) {
  analytics.push({ provider: 'Adobe Analytics', evidence: ['Adobe Analytics detected'] });
}

// Klaviyo
if (window._learnq || document.querySelector('script[src*="klaviyo"]')) {
  analytics.push({ provider: 'Klaviyo', evidence: ['Klaviyo tracking detected'] });
}

// Attentive
if (window.__attentive || document.querySelector('script[src*="attentive"]')) {
  analytics.push({ provider: 'Attentive', evidence: ['Attentive detected'] });
}

// New Relic
if (window.NREUM || window.newrelic) {
  analytics.push({ provider: 'New Relic', evidence: ['New Relic browser agent detected'] });
}

// Datadog RUM
if (window.DD_RUM || document.querySelector('script[src*="datadoghq"]')) {
  analytics.push({ provider: 'Datadog RUM', evidence: ['Datadog RUM detected'] });
}

// Sentry
if (window.Sentry || window.__SENTRY__) {
  analytics.push({ provider: 'Sentry', evidence: ['Sentry error tracking detected'] });
}

console.log(JSON.stringify(analytics));
```

---

## CDN / Infrastructure Detection

Check response headers on the main document or key assets:

```js
// Run this via fetch to inspect headers
const resp = await fetch(window.location.href, { method: 'HEAD', credentials: 'same-origin' });
const headers = {};
for (const [k, v] of resp.headers.entries()) headers[k] = v;

const cdn = {};

// Cloudflare
if (headers['cf-ray'] || headers['cf-cache-status'] || headers['server'] === 'cloudflare') {
  cdn.provider = 'Cloudflare';
  cdn.evidence = [];
  if (headers['cf-ray']) cdn.evidence.push(`cf-ray: ${headers['cf-ray']}`);
}

// Fastly
if (headers['x-served-by'] || headers['x-cache']?.includes('MISS from') || headers['via']?.includes('varnish')) {
  cdn.provider = 'Fastly';
  cdn.evidence = [];
  if (headers['x-served-by']) cdn.evidence.push(`x-served-by: ${headers['x-served-by']}`);
  if (headers['x-cache']) cdn.evidence.push(`x-cache: ${headers['x-cache']}`);
}

// Akamai
if (headers['x-akamai-transformed'] || headers['server']?.includes('AkamaiGHost')) {
  cdn.provider = 'Akamai';
  cdn.evidence = ['Akamai headers detected'];
}

// AWS CloudFront
if (headers['x-amz-cf-id'] || headers['x-amz-cf-pop'] || headers['via']?.includes('CloudFront')) {
  cdn.provider = 'AWS CloudFront';
  cdn.evidence = [];
  if (headers['x-amz-cf-id']) cdn.evidence.push('x-amz-cf-id present');
  if (headers['x-amz-cf-pop']) cdn.evidence.push(`x-amz-cf-pop: ${headers['x-amz-cf-pop']}`);
}

// Vercel
if (headers['x-vercel-id'] || headers['server'] === 'Vercel') {
  cdn.provider = 'Vercel';
  cdn.evidence = ['Vercel headers detected'];
}

// Netlify
if (headers['x-nf-request-id'] || headers['server'] === 'Netlify') {
  cdn.provider = 'Netlify';
  cdn.evidence = ['Netlify headers detected'];
}

// Google Cloud CDN
if (headers['via']?.includes('google') || headers['server']?.includes('Google')) {
  cdn.provider = 'Google Cloud';
  cdn.evidence = ['Google server headers detected'];
}

// Also check asset domains
const assetDomains = new Set();
document.querySelectorAll('script[src], link[href], img[src]').forEach(el => {
  const url = el.src || el.href;
  if (url) {
    try { assetDomains.add(new URL(url).hostname); } catch {}
  }
});

cdn.assetDomains = [...assetDomains].filter(d => d !== window.location.hostname).slice(0, 20);
console.log(JSON.stringify(cdn));
```

### Known Asset CDN Domains

| Domain Pattern | CDN |
|----------------|-----|
| `*.cloudflare.com` | Cloudflare |
| `*.cloudfront.net` | AWS CloudFront |
| `*.akamaihd.net`, `*.akamaized.net` | Akamai |
| `*.fastly.net` | Fastly |
| `*.cdn.shopify.com` | Shopify CDN |
| `*.googleapis.com` | Google |
| `*.azureedge.net` | Azure CDN |
| `*.imgix.net` | Imgix |
| `*.cloudinary.com` | Cloudinary |

---

## Other Integrations

### Reviews

```js
const reviews = {};

// Bazaarvoice
if (window.BV || document.querySelector('script[src*="bazaarvoice"]') || document.querySelector('[data-bv-show]')) {
  reviews.provider = 'Bazaarvoice';
  reviews.evidence = [];
  if (window.BV) reviews.evidence.push('window.BV present');
  if (document.querySelector('[data-bv-show]')) reviews.evidence.push('BV data attributes in DOM');
}

// Yotpo
if (window.yotpo || document.querySelector('script[src*="yotpo"]') || document.querySelector('.yotpo')) {
  reviews.provider = 'Yotpo';
  reviews.evidence = ['Yotpo detected'];
}

// PowerReviews
if (window.POWERREVIEWS || document.querySelector('script[src*="powerreviews"]')) {
  reviews.provider = 'PowerReviews';
  reviews.evidence = ['PowerReviews detected'];
}

// Trustpilot
if (document.querySelector('script[src*="trustpilot"]') || document.querySelector('[data-businessunit-id]')) {
  reviews.provider = 'Trustpilot';
  reviews.evidence = ['Trustpilot widget detected'];
}

// Judge.me
if (document.querySelector('script[src*="judge.me"]') || document.querySelector('.jdgm-widget')) {
  reviews.provider = 'Judge.me';
  reviews.evidence = ['Judge.me detected'];
}

// Stamped.io
if (window.StampedFn || document.querySelector('script[src*="stamped"]')) {
  reviews.provider = 'Stamped.io';
  reviews.evidence = ['Stamped.io detected'];
}

// Okendo
if (document.querySelector('script[src*="okendo"]') || document.querySelector('[data-oke-reviews-widget]')) {
  reviews.provider = 'Okendo';
  reviews.evidence = ['Okendo detected'];
}

console.log(JSON.stringify(reviews));
```

### Chat Widgets

```js
const chat = {};

// Zendesk
if (window.zE || document.querySelector('script[src*="zendesk"]') || document.querySelector('#launcher, [data-product="web_widget"]')) {
  chat.provider = 'Zendesk';
  chat.evidence = ['Zendesk widget detected'];
}

// Intercom
if (window.Intercom || document.querySelector('script[src*="intercom"]')) {
  chat.provider = 'Intercom';
  chat.evidence = ['Intercom detected'];
}

// Drift
if (window.drift || document.querySelector('script[src*="drift"]')) {
  chat.provider = 'Drift';
  chat.evidence = ['Drift detected'];
}

// LiveChat
if (window.LiveChatWidget || document.querySelector('script[src*="livechat"]')) {
  chat.provider = 'LiveChat';
  chat.evidence = ['LiveChat detected'];
}

// Gorgias
if (document.querySelector('script[src*="gorgias"]') || window.GorgiasChat) {
  chat.provider = 'Gorgias';
  chat.evidence = ['Gorgias detected'];
}

// Gladly
if (document.querySelector('script[src*="gladly"]') || window.Gladly) {
  chat.provider = 'Gladly';
  chat.evidence = ['Gladly detected'];
}

// Tidio
if (window.tidioChatApi || document.querySelector('script[src*="tidio"]')) {
  chat.provider = 'Tidio';
  chat.evidence = ['Tidio detected'];
}

// Kustomer
if (window.Kustomer || document.querySelector('script[src*="kustomer"]')) {
  chat.provider = 'Kustomer';
  chat.evidence = ['Kustomer detected'];
}

console.log(JSON.stringify(chat));
```

### Payment Providers

```js
const payments = [];

// Stripe
if (window.Stripe || document.querySelector('script[src*="js.stripe.com"]')) {
  payments.push({ provider: 'Stripe', evidence: ['Stripe.js loaded'] });
}

// PayPal
if (window.paypal || document.querySelector('script[src*="paypal.com"]')) {
  payments.push({ provider: 'PayPal', evidence: ['PayPal SDK loaded'] });
}

// Klarna
if (window.Klarna || document.querySelector('script[src*="klarna"]')) {
  payments.push({ provider: 'Klarna', evidence: ['Klarna detected'] });
}

// Afterpay / Clearpay
if (window.afterpay || document.querySelector('script[src*="afterpay"]') || document.querySelector('afterpay-placement')) {
  payments.push({ provider: 'Afterpay', evidence: ['Afterpay detected'] });
}

// Affirm
if (window.affirm || document.querySelector('script[src*="affirm"]')) {
  payments.push({ provider: 'Affirm', evidence: ['Affirm detected'] });
}

// Apple Pay
if (document.querySelector('[class*="apple-pay"], [data-apple-pay]') || window.ApplePaySession) {
  payments.push({ provider: 'Apple Pay', evidence: ['Apple Pay supported'] });
}

// Google Pay
if (document.querySelector('[class*="google-pay"], [data-google-pay]') || window.google?.payments) {
  payments.push({ provider: 'Google Pay', evidence: ['Google Pay detected'] });
}

// Shop Pay (Shopify)
if (document.querySelector('script[src*="shop-pay"]') || document.querySelector('[data-shop-pay]')) {
  payments.push({ provider: 'Shop Pay', evidence: ['Shop Pay detected'] });
}

console.log(JSON.stringify(payments));
```

### Email / SMS Marketing

```js
const marketing = [];

// Klaviyo (also in analytics)
if (window._learnq || document.querySelector('script[src*="klaviyo"]')) {
  marketing.push({ provider: 'Klaviyo', evidence: ['Klaviyo forms/tracking detected'] });
}

// Attentive
if (window.__attentive || document.querySelector('script[src*="attentive"]')) {
  marketing.push({ provider: 'Attentive', evidence: ['Attentive SMS detected'] });
}

// Listrak
if (window._ltk || document.querySelector('script[src*="listrak"]')) {
  marketing.push({ provider: 'Listrak', evidence: ['Listrak detected'] });
}

// Braze
if (window.braze || window.appboy || document.querySelector('script[src*="braze"]')) {
  marketing.push({ provider: 'Braze', evidence: ['Braze SDK detected'] });
}

// Sailthru
if (window.Sailthru || document.querySelector('script[src*="sailthru"]')) {
  marketing.push({ provider: 'Sailthru', evidence: ['Sailthru detected'] });
}

// Iterable
if (document.querySelector('script[src*="iterable"]')) {
  marketing.push({ provider: 'Iterable', evidence: ['Iterable detected'] });
}

// Omnisend
if (window.omnisend || document.querySelector('script[src*="omnisend"]')) {
  marketing.push({ provider: 'Omnisend', evidence: ['Omnisend detected'] });
}

// Postscript
if (document.querySelector('script[src*="postscript"]')) {
  marketing.push({ provider: 'Postscript', evidence: ['Postscript SMS detected'] });
}

console.log(JSON.stringify(marketing));
```

### Loyalty & Rewards

```js
const loyalty = {};

// Smile.io
if (window.Smile || document.querySelector('script[src*="smile.io"]')) {
  loyalty.provider = 'Smile.io';
  loyalty.evidence = ['Smile.io detected'];
}

// Yotpo Loyalty
if (document.querySelector('script[src*="yotpo"][src*="loyalty"]') || document.querySelector('[data-swell-]')) {
  loyalty.provider = 'Yotpo Loyalty';
  loyalty.evidence = ['Yotpo Loyalty (Swell) detected'];
}

// LoyaltyLion
if (window.loyaltylion || document.querySelector('script[src*="loyaltylion"]')) {
  loyalty.provider = 'LoyaltyLion';
  loyalty.evidence = ['LoyaltyLion detected'];
}

console.log(JSON.stringify(loyalty));
```

### UGC / Visual Commerce

```js
const ugc = {};

// Curalate
if (window.Curalate || document.querySelector('script[src*="curalate"]')) {
  ugc.provider = 'Curalate';
  ugc.evidence = [];
  if (window.Curalate) ugc.evidence.push('window.Curalate present');
  if (document.querySelector('script[src*="curalate"]')) ugc.evidence.push('scripts from edge.curalate.com');
}

// Bazaarvoice Galleries
if (document.querySelector('[data-bv-show="photo_gallery"]')) {
  ugc.provider = 'Bazaarvoice Galleries';
  ugc.evidence = ['BV photo gallery in DOM'];
}

// Olapic (now Emplifi)
if (window.olapic || document.querySelector('script[src*="olapic"]')) {
  ugc.provider = 'Olapic';
  ugc.evidence = ['Olapic detected'];
}

// Pixlee (now Emplifi)
if (window.Pixlee || document.querySelector('script[src*="pixlee"]')) {
  ugc.provider = 'Pixlee';
  ugc.evidence = ['Pixlee detected'];
}

console.log(JSON.stringify(ugc));
```

### Affiliate / Creator Platforms

```js
const affiliate = {};

// ShopMy
if (document.querySelector('script[src*="shopmy"]')) {
  affiliate.provider = 'ShopMy';
  affiliate.evidence = ['scripts from static.shopmy.us'];
}

// ShareASale
if (document.querySelector('script[src*="shareasale"]')) {
  affiliate.provider = 'ShareASale';
  affiliate.evidence = ['ShareASale detected'];
}

// Rakuten / LinkShare
if (document.querySelector('script[src*="rakuten"]') || document.querySelector('script[src*="linksynergy"]')) {
  affiliate.provider = 'Rakuten';
  affiliate.evidence = ['Rakuten detected'];
}

// Impact
if (document.querySelector('script[src*="impact.com"]') || document.querySelector('script[src*="impactradius"]')) {
  affiliate.provider = 'Impact';
  affiliate.evidence = ['Impact detected'];
}

console.log(JSON.stringify(affiliate));
```

### Tag Management & Consent

```js
const tagMgmt = {};

// Adobe Launch (DTM)
if (window._satellite) {
  tagMgmt.provider = 'Adobe Launch';
  tagMgmt.evidence = ['window._satellite present'];
  if (document.querySelector('script[src*="adobedtm.com"]')) tagMgmt.evidence.push('scripts from assets.adobedtm.com');
}

// OneTrust
if (window.OneTrust || document.querySelector('script[src*="cookielaw"]')) {
  tagMgmt.consent = 'OneTrust';
  tagMgmt.evidence = tagMgmt.evidence || [];
  if (window.OneTrust) tagMgmt.evidence.push('window.OneTrust present');
  if (document.querySelector('script[src*="cookielaw"]')) tagMgmt.evidence.push('scripts from cdn.cookielaw.org');
}

// CookieBot
if (window.Cookiebot || document.querySelector('script[src*="cookiebot"]')) {
  tagMgmt.consent = 'CookieBot';
  tagMgmt.evidence = tagMgmt.evidence || [];
  tagMgmt.evidence.push('CookieBot detected');
}

// TrustArc
if (window.truste || document.querySelector('script[src*="trustarc"]')) {
  tagMgmt.consent = 'TrustArc';
  tagMgmt.evidence = tagMgmt.evidence || [];
  tagMgmt.evidence.push('TrustArc detected');
}

console.log(JSON.stringify(tagMgmt));
```

---

## Network Interception Setup

Use this Playwriter snippet to capture all XHR/fetch requests **and** response bodies from known search API domains:

```js
state.requests = [];
state.searchApiResponses = [];

const SEARCH_API_DOMAINS = [
  'algolianet.com', 'algolia.net', 'algolia.io',
  'searchspring.net',
  'cnstrc.com', 'constructor.io',
  'brcdn.com', 'dxpapi.com',
  'ksearchnet.com',
  'cloud.coveo.com',
  'groupbycloud.com',
  'lucidworks.com',
  '54proxy.com',
  'nosto.com',
  'typesense',
  'elastic',
];

page.on('request', req => {
  const url = req.url();
  const type = req.resourceType();
  if (type === 'xhr' || type === 'fetch') {
    state.requests.push({ url, method: req.method() });
  }
});

page.on('response', async res => {
  const url = res.url();
  if (SEARCH_API_DOMAINS.some(d => url.includes(d))) {
    try {
      const body = await res.json();
      state.searchApiResponses.push({ url, status: res.status(), body });
    } catch {}
  }
});
```

**Important:** Set up both listeners **before** any navigation (Phase 2). The response listener passively captures JSON bodies from search API calls during Phases 3-5 so they can be replayed in Phase 3.5 for catalog estimation.

After navigating and interacting, analyze captured requests:

```js
// Group by known provider domains
const providers = {
  'algolia': 'Algolia',
  'searchspring': 'Searchspring',
  'cnstrc.com': 'Constructor.io',
  'constructor.io': 'Constructor.io',
  'brcdn.com': 'Bloomreach',
  'dxpapi.com': 'Bloomreach',
  'klevu': 'Klevu',
  'nosto': 'Nosto',
  'dynamicyield': 'Dynamic Yield',
  'monetate': 'Monetate',
  'richrelevance': 'RichRelevance',
  'bazaarvoice': 'Bazaarvoice',
  'yotpo': 'Yotpo',
  'powerreviews': 'PowerReviews',
  'klaviyo': 'Klaviyo',
  'attentive': 'Attentive',
  'facebook': 'Facebook',
  'tiktok': 'TikTok',
  'google-analytics': 'Google Analytics',
  'googletagmanager': 'Google Tag Manager',
  'optimizely': 'Optimizely',
  'launchdarkly': 'LaunchDarkly',
  'abtasty': 'AB Tasty',
  'stripe': 'Stripe',
  'paypal': 'PayPal',
  'groupbycloud': 'GroupBy',
};

const found = {};
for (const req of state.requests) {
  for (const [pattern, name] of Object.entries(providers)) {
    if (req.url.includes(pattern)) {
      if (!found[name]) found[name] = [];
      found[name].push(req.url.substring(0, 120));
    }
  }
}

console.log(JSON.stringify(found, null, 2));
```

---

## Catalog Size Estimation

Use these strategies in priority order after Phase 3 search. Each includes copy-paste-ready Playwriter code.

### Strategy 1: Search API Replay (best — 1-2 fetch calls)

Replay the already-intercepted search API with a broad query and `rows=0` to get only the total count.

**Step 1 — Find the API URL template from Phase 3 interception:**

```js
// Check what search API responses were captured during Phase 3
console.log('Search API responses captured:', state.searchApiResponses.length);
state.searchApiResponses.forEach((r, i) => {
  console.log(`[${i}] ${r.status} ${r.url.substring(0, 150)}`);
});
```

**Step 2 — Extract total count from the captured response (provider-specific field mapping):**

```js
function extractTotalCount(body) {
  // Bloomreach / Solr
  if (body?.response?.numFound !== undefined) return { count: body.response.numFound, field: 'response.numFound' };
  // Algolia
  if (body?.nbHits !== undefined) return { count: body.nbHits, field: 'nbHits' };
  if (body?.results?.[0]?.nbHits !== undefined) return { count: body.results[0].nbHits, field: 'results[0].nbHits' };
  // Constructor.io
  if (body?.response?.total_num_results !== undefined) return { count: body.response.total_num_results, field: 'response.total_num_results' };
  // Searchspring
  if (body?.totalResults !== undefined) return { count: body.totalResults, field: 'totalResults' };
  if (body?.pagination?.totalResults !== undefined) return { count: body.pagination.totalResults, field: 'pagination.totalResults' };
  // Klevu
  if (body?.meta?.totalResultsFound !== undefined) return { count: body.meta.totalResultsFound, field: 'meta.totalResultsFound' };
  // GroupBy
  if (body?.totalRecordCount !== undefined) return { count: body.totalRecordCount, field: 'totalRecordCount' };
  // Coveo
  if (body?.totalCount !== undefined) return { count: body.totalCount, field: 'totalCount' };
  // Elasticsearch
  if (body?.hits?.total?.value !== undefined) return { count: body.hits.total.value, field: 'hits.total.value' };
  if (body?.hits?.total !== undefined && typeof body.hits.total === 'number') return { count: body.hits.total, field: 'hits.total' };
  // Generic fallbacks
  if (body?.total !== undefined && typeof body.total === 'number') return { count: body.total, field: 'total' };
  if (body?.count !== undefined && typeof body.count === 'number') return { count: body.count, field: 'count' };
  return null;
}

// Try extracting from already-captured responses first
for (const r of state.searchApiResponses) {
  const result = extractTotalCount(r.body);
  if (result) {
    console.log(`Found count ${result.count} via field "${result.field}" from ${r.url.substring(0, 100)}`);
    state.catalogEstimate = { count: result.count, method: 'search_api_captured', field: result.field, url: r.url };
    break;
  }
}
if (!state.catalogEstimate) console.log('No count found in captured responses — proceed to replay');
```

**Step 3 — Replay with wildcard query and `rows=0` to get unfiltered total:**

> **Note:** `extractTotalCount` must be redefined here because Playwriter `execute` calls don't share function scope. Copy the function from Step 2.

```js
// Must redefine — Playwriter execute calls have isolated scope
function extractTotalCount(body) {
  if (body?.response?.numFound !== undefined) return { count: body.response.numFound, field: 'response.numFound' };
  if (body?.nbHits !== undefined) return { count: body.nbHits, field: 'nbHits' };
  if (body?.results?.[0]?.nbHits !== undefined) return { count: body.results[0].nbHits, field: 'results[0].nbHits' };
  if (body?.response?.total_num_results !== undefined) return { count: body.response.total_num_results, field: 'response.total_num_results' };
  if (body?.totalResults !== undefined) return { count: body.totalResults, field: 'totalResults' };
  if (body?.pagination?.totalResults !== undefined) return { count: body.pagination.totalResults, field: 'pagination.totalResults' };
  if (body?.meta?.totalResultsFound !== undefined) return { count: body.meta.totalResultsFound, field: 'meta.totalResultsFound' };
  if (body?.totalRecordCount !== undefined) return { count: body.totalRecordCount, field: 'totalRecordCount' };
  if (body?.totalCount !== undefined) return { count: body.totalCount, field: 'totalCount' };
  if (body?.hits?.total?.value !== undefined) return { count: body.hits.total.value, field: 'hits.total.value' };
  if (body?.hits?.total !== undefined && typeof body.hits.total === 'number') return { count: body.hits.total, field: 'hits.total' };
  if (body?.total !== undefined && typeof body.total === 'number') return { count: body.total, field: 'total' };
  if (body?.count !== undefined && typeof body.count === 'number') return { count: body.count, field: 'count' };
  return null;
}

// Build replay URL from captured search API call
const apiResp = state.searchApiResponses[0];
if (!apiResp) { console.log('No search API captured — skip to Strategy 2'); }
else {
  const u = new URL(apiResp.url);
  // Strip query-narrowing params, set broad query
  u.searchParams.set('q', '*');
  u.searchParams.set('rows', '0');
  // Remove filters that narrow results
  ['fq', 'filter', 'filters', 'facetFilters', 'refinementList', 'numericFilters'].forEach(p => u.searchParams.delete(p));

  const replayUrl = u.toString();
  console.log('Replaying:', replayUrl.substring(0, 200));

  const data = await page.evaluate(async (url) => {
    const res = await fetch(url);
    if (!res.ok) return { error: res.status };
    return res.json();
  }, replayUrl);

  if (data.error) {
    console.log(`Wildcard query failed (${data.error}), retrying with q=a`);
    u.searchParams.set('q', 'a');
    const data2 = await page.evaluate(async (url) => {
      const res = await fetch(url);
      if (!res.ok) return { error: res.status };
      return res.json();
    }, u.toString());
    if (!data2.error) {
      const result = extractTotalCount(data2);
      if (result) {
        state.catalogEstimate = { count: result.count, method: 'search_api_replay_broad', field: result.field, query: 'a', url: u.toString() };
        console.log(`Catalog estimate: ~${result.count} (via "${result.field}", query="a")`);
      }
    }
  } else {
    const result = extractTotalCount(data);
    if (result) {
      state.catalogEstimate = { count: result.count, method: 'search_api_replay_wildcard', field: result.field, query: '*', url: replayUrl };
      console.log(`Catalog estimate: ${result.count} (via "${result.field}", query="*")`);
    }
  }
}
```

### Strategy 2: PLP "X of Y items" Text (0 extra calls)

Extract totals from visible text on the current page (search results or PLP from Phase 4).

```js
const bodyText = await page.evaluate(() => document.body.innerText);
const patterns = [
  /(\d[\d,]+)\s+(?:total\s+)?(?:results?|items?|products?)\s+found/i,
  /showing\s+\d+[\s–-]+\d+\s+of\s+(\d[\d,]+)/i,
  /(\d[\d,]+)\s+of\s+(\d[\d,]+)\s+(?:items?|products?|results?)/i,
  /(\d[\d,]+)\s+(?:items?|products?|results?)/i,
  /total[:\s]+(\d[\d,]+)/i,
];
for (const pat of patterns) {
  const m = bodyText.match(pat);
  if (m) {
    // Use the largest captured group (most likely the total)
    const nums = m.slice(1).filter(Boolean).map(n => parseInt(n.replace(/,/g, ''), 10));
    const total = Math.max(...nums);
    if (total > 0) {
      console.log(`PLP text match: "${m[0]}" → ${total}`);
      if (!state.catalogEstimate) {
        state.catalogEstimate = { count: total, method: 'plp_text_extraction', matchedText: m[0] };
      }
      break;
    }
  }
}
```

### Strategy 3: Sitemap Product Count (1-4 fetch calls)

Count product URLs in the sitemap.

```js
const origin = new URL(page.url()).origin;
const sitemapUrls = [`${origin}/sitemap.xml`, `${origin}/sitemap_index.xml`, `${origin}/sitemap_products.xml`, `${origin}/sitemap-products.xml`];
const productPatterns = ['/p/', '/product/', '/products/', '/dp/', '/ip/', '/pd/', '/-p-'];

for (const smUrl of sitemapUrls) {
  const xml = await page.evaluate(async (url) => {
    try {
      const res = await fetch(url);
      if (!res.ok) return null;
      return await res.text();
    } catch { return null; }
  }, smUrl);
  if (!xml) continue;

  // Count <loc> entries matching product URL patterns
  const locs = xml.match(/<loc>([^<]+)<\/loc>/gi) || [];
  const productLocs = locs.filter(loc => productPatterns.some(p => loc.includes(p)));

  if (productLocs.length > 0) {
    console.log(`Sitemap ${smUrl}: ${productLocs.length} product URLs out of ${locs.length} total`);
    if (!state.catalogEstimate) {
      state.catalogEstimate = { count: productLocs.length, method: 'sitemap_count', sitemapUrl: smUrl, totalUrls: locs.length };
    }
    break;
  } else if (locs.length > 0) {
    console.log(`Sitemap ${smUrl}: ${locs.length} URLs but no product pattern matches`);
  }
}
```

### Strategy 4: Fallback Lower Bound (0 extra calls)

Use whatever product count is visible on the current page as a minimum.

```js
const visibleCount = await page.evaluate(() => {
  const cards = document.querySelectorAll('[class*="product"], [data-product-id], [data-item-id], .grid-item, .product-card, .product-tile');
  return cards.length;
});
if (visibleCount > 0 && !state.catalogEstimate) {
  console.log(`Visible products on page: ${visibleCount} (lower bound only)`);
  state.catalogEstimate = { count: visibleCount, method: 'visible_count_lower_bound', note: 'This is a lower bound — only counts products visible on the current page' };
}
```
