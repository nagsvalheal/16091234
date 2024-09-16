// To import Libraries
import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
// To import Apex Classes
import GET_JUST_FOR_ME_ARTICLES from '@salesforce/apex/BI_PSPB_PersonalizedArticlesCtrl.retrieveStorageArticles';
import GET_PERSONALIZED_ARTICLES from '@salesforce/apex/BI_PSPB_PersonalizedArticlesCtrl.getPersonalizedArticles';
import RETRIEVE_MEDIA_FROM_CMS_NEWS from '@salesforce/apex/BI_PSPB_CmsCtrl.retrieveMediaFromCMSNews';
import SHOW_FILTER_RESPONSE from '@salesforce/apex/BI_PSP_CaregiverAndPatientCtrl.getAssessmentsByCurrentUserName';
import PATIENT_STATUS from '@salesforce/apex/BI_PSPB_TreatmentVideoCtrl.patientStatus';
import INSERT_JUST_FOR_ME_ARTICLES from '@salesforce/apex/BI_PSPB_PersonalizedArticlesCtrl.insertPersonalizedArticles';

import UPDATE_REACTION from '@salesforce/apex/BI_PSPB_ArticleLikeCtrl.updateReaction';
// To import Custom Labels
import {LABELS, MINSMAP} from 'c/biPspbLabelForInfoCenter';
// To get Current UserId
import ID from '@salesforce/user/Id';

export default class BiPspbArticleCategoryParent extends LightningElement {

	loadMoreLabel = LABELS.LOAD_MORE;
	showJustForMe = false;
	userId = ID;
	treatmentSpevigoCategory;
	treatmentCategoryAnalytics;
	final = '';
	count = 1;
	stateResult = '';
	showSearch = false;
	whatIsGpp;
	gppHealth;
	talkHcp;
	manageGpp;
	flaresCategory;
	justForMeCategory;
	justForMeArticleList = [];
	showLoadMore = false;
	originalSearchItemsOfSearch = [];
	currentLength;
	treatmentCategory;
	spevigoArticle;
	touch = false;
	down = true;
	up = false;
	patientStatusValue = '';
	articleList = [];
	searchItems = [];
	originalSearchItems = [];
	storedJustForList = [];
	urlq;
	currentPageUrl;
	urlSegments;
	baseUrl;
	showBrandedNav = false;
	spevigoSpace = false;
	results = [];
	result = [];
	showSpinner=false;
	renderedChildrenCount = 0;
	channelName = LABELS.CHANNEL_NAME;
	siteUrlq;
	topics = MINSMAP;
	defaultClass = 'end-btn';
	selectedClass = 'end-btn-selected';
	anchorText = 'menuList';
	anchorTextForSpevigo = 'menuList';
	articles = LABELS.ARTICLES;
	justForMeLabel =LABELS.JUST_FOR_ME_CATEGORY;
	whatIsGppLabel = LABELS.WHAT_GPP_LABEL;
	gppHealthCategoryLabel = LABELS.GPP_HEALTH_CATEGORY;
	manageGppCategoryLabel = LABELS.MANAGE_GPP_CATEGORY;
	flaresCategoryLabel = LABELS.FLARES_CATEGORY;
	talkHcpCategoryLabel=LABELS.TALK_HCP_CATEGORY
	patientTreatmentVideos = LABELS.PATIENT_TREATMENT_VIDEOS;
	spevigoArticleLabel=LABELS.SPEVIGO_ARTICLES;
	minutes = LABELS.MINUTES;
	titlesMap = {
		[LABELS.WHAT_IS_GPP_CATEGORY]: [
			LABELS.RARE_GPP_LABEL,
			LABELS.FACTS_GPP_LABEL,
			LABELS.WHAT_GPP_LABEL,
			LABELS.GPP_CONTAGIOUS_LABEL,
			LABELS.WHY_DO_I_HAVE_GPP_LABEL
		],
		[LABELS.GPP_HEALTH_CATEGORY]: [
			LABELS.TALK_GPP_LABEL,
			LABELS.NOT_ALONE_LABEL,
			LABELS.DIAGNOSIS_GPP_LABEL,
			LABELS.FEELING_EXCLUDED_LABEL,
			LABELS.FRIENDS_FAMILY_LABEL
		],
		[LABELS.TALK_HCP_CATEGORY]: [
			LABELS.GPP_COMORBIDITIES_LABEL,
			LABELS.VISIT_DOCTOR_LABEL,
			LABELS.ASK_DOCTOR_LABEL,
			LABELS.SEEK_MEDICARE_LABEL,
			LABELS.DERMATOLOGIST_LABEL
		],
		[LABELS.MANAGE_GPP_CATEGORY]: [
			LABELS.POSITIVE_CHOICES_LABEL,
			LABELS.GPP_PREGNANCY_LABEL,
			LABELS.GPP_INTIMACY_LABEL,
			LABELS.SEEK_EMERGENCY_LABEL,
			LABELS.COMPLICAT_GPP_LABEL
		],
		[LABELS.FLARES_CATEGORY]: [
			LABELS.RECOGNIZING_FLARES_LABEL,
			LABELS.MANAGE_FLARE_LABEL,
			LABELS.MANAGE_GPP_SYMPTOMS_LABEL,
			LABELS.MANAGE_SCARS_LABEL
		],
		[LABELS.JUST_FOR_ME_CATEGORY]: []
	};
	searchTerm = '';

	totalChildren = 2; // Total number of child components

	// Getter to check if all children have rendered
	get allChildrenRendered() {
		return this.renderedChildrenCount >= this.totalChildren;
	}
/**
	 * @param {boolean} val
	 */
	// Setter to increment the count when a child is rendered
	set childRendered(val) {
		if (val) {
			this.renderedChildrenCount++;
			if (this.allChildrenRendered) {
				this.showSpinner = false;
			}
		}
	}

	handleChildRendered(event) {
	this.childRendered = event.detail.rendered;
	}

	// To retrieve current site url
	connectedCallback() {
		try {
			this.showSpinner=true;
			let globalThis = window;
			// Check the condition
			let currentUrl = globalThis.location.href;

			// Create a URL object
			let urlObject = new URL(currentUrl);

			// Get the path
			let path = urlObject.pathname;

			// Split the path using '/' as a separator
			let pathComponents = path.split('/');

			// Find the component you need (in this case, 'Branded')
			let desiredComponent = pathComponents.find((component) =>
				[LABELS.BRANDED_URL.toLowerCase(), LABELS.UNASSIGNED_URL.toLowerCase()].includes(
					component.toLowerCase()
				)
			);

			if (desiredComponent.toLowerCase() === LABELS.BRANDED_URL.toLowerCase()) {
				this.urlq = LABELS.BRANDED_URL;
				this.siteUrlq = LABELS.BRANDED_SITE_URL;
			} else {
				this.urlq = LABELS.UNASSIGNED_URL;
				this.siteUrlq = LABELS.UNASSIGNED_SITE_URL;
			}
			this.currentPageUrl = globalThis.location.href;
			this.urlSegments = this.currentPageUrl.split('/');
			this.baseUrl = `${this.urlSegments[0]}//${this.urlSegments[2]}`;

			if (this.urlq === LABELS.BRANDED_URL) {
				if (
					this.patientStatusValue === LABELS.ACUTE_STATUS ||
					this.patientStatusValue === LABELS.CHRONIC_STATUS
				) {
					this.showBrandedNav = true;
				} else {
					this.showBrandedNav = false;
				}
			} else {
				this.showBrandedNav = false;

				if (this.patientStatusValue === LABELS.ACUTE_STATUS) {
					this.showBrandedNav = true;
				} else if (this.patientStatusValue === LABELS.UNASSIGNED_STATUS) {
					this.showBrandedNav = false;
				} else {
					this.showBrandedNav = false;
				}
			}

		} catch (error) {
			this.navigateToErrorPage(error.message); // Catching Potential Error from Lwc
		}
	}

	// To navigate to information center landing page
	openArticlesPage() {
		window.location.assign(this.siteUrlq + LABELS.LANDING_PAGE);
	}

	// To navigate landing informaton center category page
	openSpevigoCategory() {

		if(this.patientStatusValue === LABELS.CHRONIC_STATUS){
			window.location.assign(this.siteUrlq+LABELS.CATEGORY_PAGE+LABELS.FLARE_PREVENTION_LABEL)
		}
		else{
			window.location.assign(this.siteUrlq+ LABELS.CATEGORY_PAGE + LABELS.FLARE_TREATMENT_LABEL)
		}
	}

	// To navigate to acute or chronic customized video page
	openPTVPage() {
		if (this.patientStatusValue === LABELS.ACUTE_STATUS) {
			window.location.assign(this.siteUrlq + LABELS.ACUTE_VIDEO_PAGE);
			this.treatmentSpevigoCategory = LABELS.FLARE_TREATMENT_LABEL;
			this.treatmentCategoryAnalytics = LABELS.FLARE_TREATMENT_CATEGORY;
		} else if (this.patientStatusValue === LABELS.CHRONIC_STATUS) {
			if (this.urlq === LABELS.BRANDED_URL) {
				window.location.assign(this.siteUrlq + LABELS.CHRONIC_VIDEO_PAGE);
			} else {
				window.location.assign(this.siteUrlq + LABELS.ACUTE_VIDEO_PAGE);
			}
			this.treatmentSpevigoCategory = LABELS.FLARE_PREVENTION_LABEL;
			this.treatmentCategoryAnalytics = LABELS.FLARE_PREVENTION_CATEGORY;
		}
	}

	// To retrieve patient status (acute or chronic or unassigned)
	@wire(PATIENT_STATUS)
	wiredPatientStatus({ error, data }) {
		try {
			if (data) {
				this.patientStatusValue = data;

				if (this.patientStatusValue === LABELS.ACUTE_STATUS) {
						this.showBrandedNav = true;
					this.treatmentSpevigoCategory = LABELS.FLARE_TREATMENT_LABEL;
					this.treatmentCategoryAnalytics = LABELS.FLARE_TREATMENT_CATEGORY;
				} else if (this.patientStatusValue === LABELS.CHRONIC_STATUS) {
					this.showBrandedNav = true;

					this.treatmentSpevigoCategory = LABELS.FLARE_PREVENTION_LABEL;
					this.treatmentCategoryAnalytics = LABELS.FLARE_PREVENTION_CATEGORY;
				} else if (this.patientStatusValue === LABELS.UNASSIGNED_STATUS) {
					this.showBrandedNav = false;
				} else if (this.urlq === LABELS.BRANDED_URL) {
					if (this.patientStatusValue === LABELS.CHRONIC_STATUS) {
						this.showBrandedNav = true;
						this.treatmentSpevigoCategory = LABELS.FLARE_PREVENTION_LABEL;
						this.treatmentCategoryAnalytics = LABELS.FLARE_PREVENTION_CATEGORY;
					}
				}  else {
						this.showBrandedNav = false;
						this.treatmentSpevigoCategory = LABELS.FLARE_TREATMENT_LABEL;
						this.treatmentCategoryAnalytics = LABELS.FLARE_TREATMENT_CATEGORY;
					}
					this.navigatePatientSite();
				// Handle the data
			} else if (error) {
				this.navigateToErrorPage(error.body.message); // Catching Potential Error from Apex
			} else {
				this.patientStatusValue = '';
			}
		} catch (err) {
			this.navigateToErrorPage(err.message); // Catching Potential Error from Lwc
		}
	}

	/* If user having null assessment record then disabled the just for me navigation */
	// To retrieve lets personalized questionaires assessment data
	@wire(SHOW_FILTER_RESPONSE,{categoryname: LABELS.INTRODUCTION_CATEGORY})
	wiredShowFilterResponse({ error, data }) {
		try {
			if (data) {
				this.showJustForMe = false;

				let showresponsedata = data;
				if (showresponsedata.length === 1 && showresponsedata[0].BI_PSP_StatusForPersonalization__c===LABELS.COMPLETE_STATUS ) {
					this.showJustForMe = true;
				} else {
					this.showJustForMe = false;
				}
			} else if (error) {
				this.navigateToErrorPage(error.body.message); // Catching Potential Error from Apex
			} else if (data === null) {
				this.showJustForMe = false;
			}
		} catch (err) {
			this.navigateToErrorPage(err.message); // Catching Potential Error from Lwc
		}
	}

	// To retrieve the CMS article contents
	@wire(RETRIEVE_MEDIA_FROM_CMS_NEWS, { channelName: '$channelName' })
	wiredData({ error, data }) {
		try {
			if (data) {
				let objStr = JSON.parse(data);
				let timestamp = new Date().getTime();
				let cbValue = `cb=${timestamp}`;

				objStr.map((element) => (this.results = [
					...this.results,
					{
						image: element.url + '?' + cbValue,
						text: element.title,
						text2: element.subtitle,
						page: element.url,
						articlehe: LABELS.ARTICLE_STRING + ' ' + element.title,
					}
				]));

				if (this.results.length > 0) {
					this.articleList = this.results;
					this.originalSearchItems = this.results;
				
					// Chain the Promises for GET_PERSONALIZED_ARTICLES and GET_JUST_FOR_ME_ARTICLES
					GET_PERSONALIZED_ARTICLES()
						.then((arlist) => {
							this.justForMeArticleList = JSON.parse(JSON.stringify(arlist));
							// Return the next API call
							return GET_JUST_FOR_ME_ARTICLES();
						})
						.then((articles) => {
							if(articles ===''){
								this.storedJustForList = [];
							}
							else{
							this.storedJustForList = JSON.parse(articles);
							}
							// Ensure pageReferenceLogic runs only after both API calls
							this.pageReferenceLogic();
							// Increment renderedChildrenCount
							this.renderedChildrenCount = this.renderedChildrenCount + 1;
							// Check if all children are rendered and hide spinner if so
							if (this.allChildrenRendered) {
								this.showSpinner = false;
							}
						})
						.catch((err) => {
							this.navigateToErrorPage(err.body.message); // Handle any errors from either Apex call
						});
				}
			}
			else if (error) {
				this.navigateToErrorPage(error.body.message);// Catching Potential Error from Lwc
			}
		} catch (err) {
			this.navigateToErrorPage(err.message);// Catching Potential Error
		}
	}

	// Navigate to Chronic user to branded site and Actue & Unassigned user to Unassigned site
	navigatePatientSite(){
		if((this.patientStatusValue === LABELS.UNASSIGNED_STATUS|| this.patientStatusValue === LABELS.ACUTE_STATUS) && this.urlq === LABELS.BRANDED_URL){
			window.location.href = this.currentPageUrl.replace(LABELS.BRANDED_URL,LABELS.UNASSIGNED_URL);
	}
	else if(this.patientStatusValue === LABELS.CHRONIC_STATUS && this.urlq === LABELS.UNASSIGNED_URL){
		window.location.href = this.currentPageUrl.replace(LABELS.UNASSIGNED_URL,LABELS.BRANDED_URL);
	}
	}
	// Clear search input
	clearInput() {
		let inputElement = this.template.querySelector('.search-bar');
		if (inputElement) {
			inputElement.value = '';
		}
	}

	secureRandom() {
		const array = new Uint32Array(1);
		window.crypto.getRandomValues(array); // Generate a random value
		return array[0] / (0xFFFFFFFF + 1); // Normalize to 0 to 1
	}

	// Check both array equal or not
	arraysEqual(arr1, arr2) {
		if (arr1.length !== arr2.length) return false;
		for (let i = 0; i < arr1.length; i++) {
			if (!arr2.includes(arr1[i])) return false;
		}
		return true;
	}

	// Filter the articles without repetition
	getRandomElementsWithoutRepetition() {
		let personalizedArticles;
		let c=0;
		if(this.getCurrentTimeAMPM() === '8:00 PM'){
			personalizedArticles =this.randomizedArticles();
			c=1;
		}
		// Shuffle array
		let localArticles = this.storedJustForList;
		if(localArticles.length!==0 && this.arraysEqual([...this.justForMeArticleList], [...localArticles])){
			personalizedArticles = this.storedJustForList;
			c=1;
		}
		if (c===0){
			personalizedArticles = this.randomizedArticles();
		}

		return personalizedArticles;
	}

	randomizedArticles(){
		let shuffled = this.shuffleArray(this.justForMeArticleList);

		INSERT_JUST_FOR_ME_ARTICLES({ articleList: JSON.stringify(shuffled) });
		return shuffled;
	}
	getCurrentTimeAMPM() {
		const now = new Date();
		let hours = now.getHours();
		const minutes = now.getMinutes();
		const ampm = hours >= 12 ? 'PM' : 'AM';
	
		// Convert to 12-hour format
		hours = hours % 12;
		hours = hours || 12; // the hour '0' should be '12'
		
		// Add leading zero to minutes if needed
		const minutesStr = minutes < 10 ? '0' + minutes : minutes;
		
		// Format the time string
		const currentTime = `${hours}:${minutesStr} ${ampm}`;
		return currentTime;
	}
	
	matchJustForMeArticles(arr,localArticles){
		let currentArticles = arr;
		let storageArticles = localArticles;
		return JSON.stringify(currentArticles.sort()) === JSON.stringify(storageArticles.sort());
	}

	getLocalStorageArticles(){
		if(localStorage.getItem('justForMeArticles')){
			return JSON.parse(localStorage.getItem('justForMeArticles'));
		}
		return [];
	}

	// Filter the articles based on titles
	filterResultsByTitles(titlesToFilter) {
		let shuffledResults;
		if (this.stateResult === LABELS.JUST_FOR_ME_CATEGORY) {
			let justForRandomized = this.getRandomElementsWithoutRepetition();
			shuffledResults = this.randomizedJustForMeArticles(justForRandomized);
			return shuffledResults;
		} 
		shuffledResults = this.results;

		let filteredResults = [];
		let count = 1;

	for (let i = 0; i < shuffledResults.length; i++) {
		let result = shuffledResults[i];
		let titleFound = false;
		
	for (let j = 0; j < titlesToFilter.length; j++) {
		if (
			result.text.trim().toLowerCase() ===
			titlesToFilter[j].trim().toLowerCase()
		) {
			titleFound = true;
			break;
		}
	}

	if (titleFound) {
		result.count = count % 2 !== 0;
		count += 1;
		result.readtime = this.topics[result.text];
		filteredResults.push(result);
	}
}		return filteredResults;
	}

	randomizedJustForMeArticles(titlesToFilter){
		let shuffledResults = this.results;
		let filteredResults = [];
		let count = 1;

	for (let i = 0; i < titlesToFilter.length; i++) {
		for (let j = 0; j < shuffledResults.length; j++) {
			let result = shuffledResults[j];
			if (
				result.text.trim().toLowerCase() ===
				titlesToFilter[i].trim().toLowerCase()
			) {
				result.count = count % 2 !== 0;
				count += 1;
				result.readtime = this.topics[result.text];
				filteredResults.push(result);
				break;
			}
		}
	}
			return filteredResults;
	}

	shuffleArray(array) {
		let shuffled = array.slice(); // Create a copy of the original array
		const crypto = window.crypto || window.msCrypto; // Ensure compatibility for older browsers
		for (let i = shuffled.length - 1; i > 0; i--) {
			const randomArray = new Uint32Array(1);
			crypto.getRandomValues(randomArray); // Generate a random value
			let j = randomArray[0] % (i + 1); // Calculate a random index
			[shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]]; // Swap elements
		}
		return shuffled;
	}
	

	mapTags(finaltitle){
			if (finaltitle === LABELS.WHAT_IS_GPP_CATEGORY) {
				this.whatIsGpp = this.selectedClass;
				this.gppHealth = this.defaultClass;
				this.talkHcp = this.defaultClass;
				this.manageGpp = this.defaultClass;
				this.flaresCategory = this.defaultClass;
				this.justForMeCategory = this.defaultClass;
				this.treatmentCategory = this.defaultClass;
			}

			if (finaltitle === LABELS.GPP_HEALTH_CATEGORY) {
				this.whatIsGpp = this.defaultClass;
				this.gppHealth = this.selectedClass;
				this.talkHcp = this.defaultClass;
				this.manageGpp = this.defaultClass;
				this.flaresCategory = this.defaultClass;
				this.justForMeCategory = this.defaultClass;
				this.treatmentCategory = this.defaultClass;
			}

			if (finaltitle === LABELS.TALK_HCP_CATEGORY) {
				this.whatIsGpp = this.defaultClass;
				this.gppHealth = this.defaultClass;
				this.talkHcp = this.selectedClass;
				this.manageGpp = this.defaultClass;
				this.flaresCategory = this.defaultClass;
				this.justForMeCategory = this.defaultClass;
				this.treatmentCategory = this.defaultClass;
			}

			if (finaltitle === LABELS.MANAGE_GPP_CATEGORY) {
				this.whatIsGpp = this.defaultClass;
				this.gppHealth = this.defaultClass;
				this.talkHcp = this.defaultClass;
				this.manageGpp = this.selectedClass;
				this.flaresCategory = this.defaultClass;
				this.justForMeCategory = this.defaultClass;
				this.treatmentCategory = this.defaultClass;
			}

			if (finaltitle === LABELS.FLARES_CATEGORY) {
				this.whatIsGpp = this.defaultClass;
				this.gppHealth = this.defaultClass;
				this.talkHcp = this.defaultClass;
				this.manageGpp = this.defaultClass;
				this.flaresCategory = this.selectedClass;
				this.justForMeCategory = this.defaultClass;
				this.treatmentCategory = this.defaultClass;
			}
			if (finaltitle === LABELS.JUST_FOR_ME_CATEGORY) {
				this.whatIsGpp = this.defaultClass;
				this.gppHealth = this.defaultClass;
				this.talkHcp = this.defaultClass;
				this.manageGpp = this.defaultClass;
				this.flaresCategory = this.defaultClass;
				this.justForMeCategory = this.selectedClass;
				this.treatmentCategory = this.defaultClass;
			}

			if (finaltitle === LABELS.FLARE_TREATMENT_LABEL || finaltitle === LABELS.FLARE_PREVENTION_LABEL) {
				this.whatIsGpp = this.defaultClass;
				this.gppHealth = this.defaultClass;
				this.talkHcp = this.defaultClass;
				this.manageGpp = this.defaultClass;
				this.flaresCategory = this.defaultClass;
				this.justForMeCategory = this.defaultClass;
				this.treatmentCategory = this.selectedClass;
			}

			let titlesToFilter = this.titlesMap[finaltitle];
			if (titlesToFilter) {
				this.searchItems = this.filterResultsByTitles(titlesToFilter);
				this.showSearch = true;
			}
		
	}
	// To filter the articles and map their categories.
	pageReferenceLogic() {
		this.showSearch = false;
		this.searchItems = [];
		this.count = 1;
		let finaltitle = this.stateResult;
		this.final = finaltitle;

		if (this.final === LABELS.JUST_FOR_ME_CATEGORY) {
			let selectedArticleCategory = this.justForMeArticleList;
			if (selectedArticleCategory) {
				this.searchItems = this.filterResultsByTitles(selectedArticleCategory);
				this.showSearch = true;
			}

			this.updateCategorySelection(finaltitle);
			this.loadMoreLogic();

		} else if (finaltitle === LABELS.FLARE_TREATMENT_LABEL || finaltitle === LABELS.FLARE_PREVENTION_LABEL) {

			this.addSpevigoArticles(finaltitle);
			this.whatIsGpp = this.defaultClass;
			this.gppHealth = this.defaultClass;
			this.talkHcp = this.defaultClass;
			this.manageGpp = this.defaultClass;
			this.flaresCategory = this.defaultClass;
			this.justForMeCategory = this.defaultClass;
			this.treatmentCategory = this.selectedClass;
			this.anchorText ='menuList';
			this.anchorTextForSpevigo = 'menuListActive';
		}else{
			this.anchorText ='menuListActive';
			this.mapTags(finaltitle);
		}
	}

	updateCategorySelection(finaltitle){
		if (finaltitle === LABELS.JUST_FOR_ME_CATEGORY) {
			this.whatIsGpp = this.defaultClass;
			this.gppHealth = this.defaultClass;
			this.talkHcp = this.defaultClass;
			this.manageGpp = this.defaultClass;
			this.flaresCategory = this.defaultClass;
			this.justForMeCategory = this.selectedClass;
			this.treatmentCategory = this.defaultClass;
		} else if (finaltitle === LABELS.FLARE_TREATMENT_LABEL || finaltitle === LABELS.FLARE_PREVENTION_LABEL) {
			this.whatIsGpp = this.defaultClass;
			this.gppHealth = this.defaultClass;
			this.talkHcp = this.defaultClass;
			this.manageGpp = this.defaultClass;
			this.flaresCategory = this.defaultClass;
			this.justForMeCategory = this.defaultClass;
			this.treatmentCategory = this.selectedClass;
		}
	}

	loadMoreLogic(){
		this.showLoadMore = true;

		this.currentLength = 3;
		this.originalSearchItemsOfSearch = this.searchItems;
		this.searchItems = this.originalSearchItemsOfSearch.slice(
			0,
			this.currentLength
		);

		if (this.currentLength < this.originalSearchItemsOfSearch.length) {
			this.showLoadMore = true;
		} else {
			this.showLoadMore = false;
		}
	}

	addSpevigoArticles(finaltitle){
		if (finaltitle === LABELS.FLARE_TREATMENT_LABEL) {
			this.spevigoArticle = [
				LABELS.TREATING_GPP_LABEL,
				LABELS.SPEVIGO_INFUSION_LABEL,
				LABELS.WORK_IN_GPP_LABEL
			];
		} else {
			this.spevigoArticle = [
				LABELS.PREVENTION_GPP_LABEL,
				LABELS.SPEVIGO_INJECTION_LABEL,
				LABELS.WORK_IN_GPP_LABEL
			];
		}
		let selectedArticleCategory = this.spevigoArticle;
		if (selectedArticleCategory) {
			this.searchItems = this.filterResultsByTitles(selectedArticleCategory);
			this.showSearch = true;

			this.loadMoreLogic();
		}
	}
	mapButton(finaltitle){
		if (finaltitle === LABELS.WHAT_IS_GPP_CATEGORY) {
			this.whatIsGpp = this.selectedClass;
			this.gppHealth = this.defaultClass;
			this.talkHcp = this.defaultClass;
			this.manageGpp = this.defaultClass;
			this.flaresCategory = this.defaultClass;
			this.justForMeCategory = this.defaultClass;
		}

		if (finaltitle === LABELS.GPP_HEALTH_CATEGORY) {
			this.whatIsGpp = this.defaultClass;
			this.gppHealth = this.selectedClass;
			this.talkHcp = this.defaultClass;
			this.manageGpp = this.defaultClass;
			this.flaresCategory = this.defaultClass;
			this.justForMeCategory = this.defaultClass;
		}

		if (finaltitle === LABELS.TALK_HCP_CATEGORY) {
			this.whatIsGpp = this.defaultClass;
			this.gppHealth = this.defaultClass;
			this.talkHcp = this.selectedClass;
			this.manageGpp = this.defaultClass;
			this.flaresCategory = this.defaultClass;
			this.justForMeCategory = this.defaultClass;
		}

		if (finaltitle === LABELS.MANAGE_GPP_CATEGORY) {
			this.whatIsGpp = this.defaultClass;
			this.gppHealth = this.defaultClass;
			this.talkHcp = this.defaultClass;
			this.manageGpp = this.selectedClass;
			this.flaresCategory = this.defaultClass;
			this.justForMeCategory = this.defaultClass;
		}

		if (finaltitle === LABELS.FLARES_CATEGORY) {
			this.whatIsGpp = this.defaultClass;
			this.gppHealth = this.defaultClass;
			this.talkHcp = this.defaultClass;
			this.manageGpp = this.defaultClass;
			this.flaresCategory = this.selectedClass;
			this.justForMeCategory = this.defaultClass;
		}
		if (finaltitle === LABELS.JUST_FOR_ME_CATEGORY) {
			this.whatIsGpp = this.defaultClass;
			this.gppHealth = this.defaultClass;
			this.talkHcp = this.defaultClass;
			this.manageGpp = this.defaultClass;
			this.flaresCategory = this.defaultClass;
			this.justForMeCategory = this.selectedClass;
		}

		if (finaltitle === LABELS.FLARE_TREATMENT_LABEL || finaltitle === LABELS.FLARE_PREVENTION_LABEL) {
			this.whatIsGpp = this.defaultClass;
			this.gppHealth = this.defaultClass;
			this.talkHcp = this.defaultClass;
			this.manageGpp = this.defaultClass;
			this.flaresCategory = this.defaultClass;
			this.justForMeCategory = this.defaultClass;
			this.treatmentCategory = this.selectedClass;
		}
	}
	// To load the category page based on current category
	// We are unable to utilize "data" or "error" as CurrentPageReference is default API.
	@wire(CurrentPageReference)
	pageReference({ state }) {
		try {
			if (state?.id) {
				this.stateResult = state.id;
				this.showSearch = false;
				this.searchItems = [];
				this.count = 1;
				let finaltitle = state.id;
				this.final = finaltitle;
				if (this.final === LABELS.FLARE_TREATMENT_LABEL || this.final === LABELS.FLARE_PREVENTION_LABEL) {
					this.spevigoSpace = true;
				}

				if (this.final === LABELS.JUST_FOR_ME_CATEGORY) {
					this.mapJustforMeCategory(finaltitle);
				} else {
					this.mapButton(finaltitle);
				}
			}
		} catch (err) {
			this.navigateToErrorPage(err.message); // Catching Potential Error
		}
	}


	mapJustforMeCategory(finaltitle){

		if (finaltitle === LABELS.JUST_FOR_ME_CATEGORY) {
			this.whatIsGpp = this.defaultClass;
			this.gppHealth = this.defaultClass;
			this.talkHcp = this.defaultClass;
			this.manageGpp = this.defaultClass;
			this.flaresCategory = this.defaultClass;
			this.justForMeCategory = this.selectedClass;
		} else if (
			finaltitle === LABELS.FLARE_TREATMENT_LABEL ||
			finaltitle === LABELS.FLARE_PREVENTION_LABEL
		) {
			this.whatIsGpp = this.defaultClass;
			this.gppHealth = this.defaultClass;
			this.talkHcp = this.defaultClass;
			this.manageGpp = this.defaultClass;
			this.flaresCategory = this.defaultClass;
			this.justForMeCategory = this.defaultClass;
			this.treatmentCategory = this.selectedClass;
		}
	}

	handleButtonClick(event) {
		let finaltitle = event.currentTarget.dataset.name;
		UPDATE_REACTION({
			articleName: finaltitle, reaction: LABELS.VIEW_LABEL
		})
			.then(() => {
				this.titlear = LABELS.VIEW_LABEL+ ': ' + finaltitle;
			})
			.catch((error) => {
				this.navigateToErrorPage(error.body.message); // Catching Potential Error from Apex
				// Handle error, if needed
			});
		window.location.href =
			this.baseUrl + this.siteUrlq + LABELS.DETAIL_PAGE + finaltitle;
	}
	handleNavigation(event) {
		let searchiteml = event.currentTarget.dataset.name;

		window.location.href =
			this.baseUrl + this.siteUrlq + LABELS.SEARCH_PAGE + searchiteml;
	}
	handleSearch(event) {
		let searchTerm = event.target.value.toLowerCase();

		if (event.key === LABELS.ENTER_EVENT && searchTerm) {
			window.location.href =
				this.baseUrl + this.siteUrlq + LABELS.SEARCH_PAGE + searchTerm;
		}
	}

	handleSearchButtonClick() {
		// Implement your logic with the selected item
		this.handleSearch();
		// Add your navigation logic or any other actions here
	}
	handleSearchInputKeyUp(event) {
		if (event.key === LABELS.ENTER_EVENT) {
			this.handleSearch(event);
		}
	}

	handlesubmit(event) {
		this.count = 1;
		let finaltitle = event.currentTarget.dataset.name;
		let articleName = finaltitle;
		window.location.href =
			this.baseUrl + this.siteUrlq + LABELS.CATEGORY_PAGE + articleName;
	}
	loadmore() {
		this.currentLength = this.currentLength + 3;
		this.searchItems = this.originalSearchItemsOfSearch.slice(
			0,
			this.currentLength
		);
		if (this.currentLength < this.originalSearchItemsOfSearch.length) {
			this.showLoadMore = true;
		} else {
			this.showLoadMore = false;
		}
	}

	handleSearchBarFocus() {
		if (window.innerWidth > 1115) {
			this.template.querySelector(
				'hr.search-bar-border-bottom'
			).style.borderColor = '#7B4D00';
			this.template.querySelector(
				'hr.search-bar-border-bottom'
			).style.borderWidth = '2px';
			this.template.querySelector(
				'hr.search-bar-border-bottom'
			).style.transition = '0.1s';
		}
	}

	handleSearchBarBlur() {
		if (window.innerWidth > 1115) {
			this.template.querySelector(
				'hr.search-bar-border-bottom'
			).style.borderColor = 'rgba(105, 105, 105, 1)';
			this.template.querySelector(
				'hr.search-bar-border-bottom'
			).style.borderWidth = '2px';
			this.template.querySelector(
				'hr.search-bar-border-bottom'
			).style.transition = '0.1s';
		}
	}

	mobStyle(){
		let category = this.template.querySelector('.subheading');
		let display_div = this.template.querySelector('.display');
		let displayvideotab = this.template.querySelector(
			'.grid-containerNavTab'
		);

		if(category &&  display_div) {
		this.addStyleForDropDown(category,display_div);

		if (displayvideotab) {
			displayvideotab.style.display = 'none';
		}
	}
	}

	addStyleForDropDown(category,display_div){
		if (this.final === LABELS.GPP_HEALTH_CATEGORY) {
			category.style.marginLeft = '-41px';
			display_div.style.width = '154%';
		}
		if (this.final === LABELS.TALK_HCP_CATEGORY) {
				category.style.marginLeft = '-72px';
				display_div.style.width = '166%';
		}
		if (this.final === LABELS.MANAGE_GPP_CATEGORY) {
				category.style.marginLeft = '-74px';
				display_div.style.width = '166%';
		}
		if (this.final === LABELS.FLARES_CATEGORY) {
				category.style.marginLeft = '-38px';
				category.style.width = '62%';

				display_div.style.width = '151%';
		}
		if (this.final === LABELS.FLARE_TREATMENT_LABEL) {
				category.style.marginLeft = '-49px';
				display_div.style.width = '157%';
		}
		if (this.final === LABELS.FLARE_PREVENTION_LABEL) {
				category.style.marginLeft = '-48px';
				display_div.style.width = '156%';
		}
		if (this.final === LABELS.WHAT_IS_GPP_CATEGORY) {
				category.style.marginLeft = '-103px';
				display_div.style.width = '178%';
		}
		if (this.final === LABELS.JUST_FOR_ME_CATEGORY) {
				category.style.marginLeft = '-111px';
				display_div.style.width = '182%';
		}
	}

	getMobStyle(){
		let globalThis = window;
		let displayvideotab = this.template.querySelector(
			'.grid-containerNavTab'
		);

		if (globalThis.innerWidth <= 1000) {
			this.mobStyle();
		} else if (displayvideotab) {
				displayvideotab.style.display = '';
			}
	}
	// Rendering the category names of the articles for mobile responsiveness.
	renderedCallback() {
		try {
			this.getMobStyle();
		} catch (error) {
			this.navigateToErrorPage(error.message); // Catching Potential Error
		}
	}

	click() {
		this.touch = true;
		this.down = false;
		this.up = true;
	}
	notclick() {
		this.touch = false;
		this.down = true;
		this.up = false;
	}

	// navigateToErrorPage used for all the error messages caught
	navigateToErrorPage(errorMessage) {
		let globalThis = window;
		globalThis.sessionStorage.setItem('errorMessage', errorMessage);
		globalThis.location.href = this.baseUrl + this.siteUrlq + LABELS.ERROR_PAGE;
	}
}