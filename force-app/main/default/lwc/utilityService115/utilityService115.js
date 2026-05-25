import { LightningElement, api } from 'lwc';

const DEBOUNCE_DELAY = 300;
const MAX_RETRIES = 3;
const CACHE_TTL = 300000;

export default class utilityService115 extends LightningElement {
    @api recordId;
    @api config = {};

    _cache = new Map();
    _debounceTimer;
    _retryCount = 0;

    connectedCallback() {
        this.initialize();
    }

    disconnectedCallback() {
        this.cleanup();
    }

    initialize() {
        this.loadConfig();
        this.setupEventListeners();
    }

    cleanup() {
        if (this._debounceTimer) clearTimeout(this._debounceTimer);
        this._cache.clear();
    }

    loadConfig() {
        const saved = sessionStorage.getItem('utilityService115_config');
        if (saved) {
            try {
                this.config = { ...this.config, ...JSON.parse(saved) };
            } catch (e) {
                console.warn('utilityService115: Failed to parse saved config');
            }
        }
    }

    setupEventListeners() {
        window.addEventListener('resize', this.handleResize.bind(this));
    }

    handleResize() {
        if (this._debounceTimer) clearTimeout(this._debounceTimer);
        this._debounceTimer = setTimeout(() => {
            this.dispatchEvent(new CustomEvent('resize', {
                detail: { width: window.innerWidth, height: window.innerHeight }
            }));
        }, DEBOUNCE_DELAY);
    }

    @api
    async fetchData(endpoint, params = {}) {
        const cacheKey = endpoint + JSON.stringify(params);
        const cached = this._cache.get(cacheKey);
        if (cached && Date.now() - cached.ts < CACHE_TTL) {
            return cached.data;
        }

        try {
            const response = await this._fetchWithRetry(endpoint, params);
            this._cache.set(cacheKey, { data: response, ts: Date.now() });
            this._retryCount = 0;
            return response;
        } catch (error) {
            this.dispatchEvent(new CustomEvent('error', { detail: error }));
            throw error;
        }
    }

    async _fetchWithRetry(endpoint, params) {
        for (let attempt = 0; attempt <= MAX_RETRIES; attempt++) {
            try {
                return await this._doFetch(endpoint, params);
            } catch (error) {
                if (attempt === MAX_RETRIES) throw error;
                await new Promise(r => setTimeout(r, Math.pow(2, attempt) * 1000));
            }
        }
    }

    async _doFetch(endpoint, params) {
        // Simulated fetch - in real implementation would call Apex
        return { success: true, data: [], timestamp: new Date().toISOString() };
    }

    @api
    clearCache() {
        this._cache.clear();
    }

    @api
    formatCurrency(value) {
        return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(value || 0);
    }

    @api
    formatDate(value) {
        if (!value) return '';
        return new Intl.DateTimeFormat('en-US', { dateStyle: 'medium', timeStyle: 'short' }).format(new Date(value));
    }

    @api
    debounce(fn, delay = DEBOUNCE_DELAY) {
        let timer;
        return (...args) => {
            clearTimeout(timer);
            timer = setTimeout(() => fn.apply(this, args), delay);
        };
    }
}
