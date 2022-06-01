import { LightningElement  } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import GGW_AGNOSTIC from '@salesforce/resourceUrl/ggw_start_image';
export default class GgwIntro extends NavigationMixin(LightningElement) {
    title;
    header; // = 'Grant';
    displaytext;
    camaImage;
    ggwAgnostic = GGW_AGNOSTIC;
    showIntro = true;
    showStart = false;

    handleStart(){
        this.showIntro = false;
        this.showStart = true; 
    }

    handleNaviTest(){
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'GGW_Grant_Editor'
            },
            state: {
                c__recordId: 'a001D000005DsP7QAK'
            }
        });

    }    
}