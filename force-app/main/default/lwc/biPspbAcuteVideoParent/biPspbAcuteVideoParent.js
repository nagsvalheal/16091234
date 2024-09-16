// This lightning web component is used for display the acute treatment video and acute avatar message
// To import Libraries
import { LightningElement } from 'lwc';
// To import Custom Labels
import { LABELS } from 'c/biPspbLabelForInfoCenter';
// To import Apex method
import PATIENT_STATUS from '@salesforce/apex/BI_PSPB_TreatmentVideoCtrl.patientStatus';


export default class BiPspbAcuteVideoParent extends LightningElement {

	urlq;
	siteUrlq;
	currentPageUrl;
	urlSegments;
	baseUrl;
	articles = LABELS.ARTICLES;
	patientTreatmentVideos = LABELS.PATIENT_TREATMENT_VIDEOS;
	spevigoArticleLabel=LABELS.SPEVIGO_ARTICLES;
	patientStatus;

	// To navigate to information center landing page
	openAcute() {
		window.location.assign(this.siteUrlq + LABELS.LANDING_PAGE);
	}

	// To navigate to information center acute video page
	openChronic() {
		window.location.assign(this.siteUrlq + LABELS.ACUTE_VIDEO_PAGE);
	}

	// To render the subheader
	connectedCallback() {
		try {
			const globalThis = window;
			let currentUrl = globalThis.location.href; // Create a URL object
			let urlObject = new URL(currentUrl); // Get the path
			let path = urlObject.pathname; // Split the path using '/' as a separator
			let pathComponents = path.split('/'); // Find the component you need (in this case, 'Branded')
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
			this.getCurrentPatientStatus();
		} catch (error) {
			this.navigateToErrorPage(error.message); // Catching Potential Error
		}
	}

		getCurrentPatientStatus(){
			PATIENT_STATUS()
			.then(data => {
				this.patientStatus = data;
				if(this.patientStatus ===LABELS.CHRONIC_STATUS){
					this.siteUrlq = LABELS.BRANDED_SITE_URL;
				}
				else{
					this.siteUrlq = LABELS.UNASSIGNED_SITE_URL;
				}
				this.navigatePatientSite();
			})
			.catch(error => {
				this.navigateToErrorPage(error.body.message); // Catching Potential Error from Apex
			})
		}

		navigatePatientSite(){
			const globalThis = window;
			if(this.patientStatus === LABELS.CHRONIC_STATUS){
				globalThis.location.href = this.siteUrlq + LABELS.CHRONIC_VIDEO_PAGE;
			}
		}
		
		// Navigate to spevigo article category
		openSpevigoCategory() {
			window.location.assign(this.siteUrlq+LABELS.CATEGORY_PAGE+LABELS.FLARE_TREATMENT_LABEL)
		}
	
	// navigateToErrorPage used for all the error messages caught
	navigateToErrorPage(errorMessage) {
		let globalThis = window;
		globalThis.sessionStorage.setItem('errorMessage', errorMessage);
		globalThis.location.assign(this.siteUrlq + LABELS.ERROR_PAGE); 
	}
}