import { LightningElement, api, track } from 'lwc';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getNoteInfo from '@salesforce/apex/ASI_CRM_VisitationPlanDetailTodayCtr.getNote';
import saveNote from '@salesforce/apex/ASI_CRM_VisitationPlanDetailTodayCtr.upsertNote';
import resource from '@salesforce/resourceUrl/ASI_CRM_VisitationPlan_Resource';

export default class ASI_CRM_VisitationDetail_NewNote_LWC extends LightningElement {

    // parameters = {};
    // RecordId = '';
    Action = '';
    @api NoteId = '';
    @api ParentId = '';
    @track Title = '';
    @track Content = '';

    
    connectedCallback() {

        Promise.all([
			loadStyle(this, resource + '/sweetalert2.min.css'),
			loadScript(this, resource + '/sweetalert2.min.js')
		])
		.then(() => {
			window.addEventListener('onhashchange', this.locationHashChanged);
        });
        
        // this.parameters = JSON.parse(this.getQueryParameters());
        
    }
    locationHashChanged()
	{
		this.parameters = this.getQueryParameters();
        if(this.parameters.c__nid == 'Create Note')
        {
            this.Action = this.parameters.c__nid;
            this.NoteId = null;
        }
        else
        {
            this.Action = 'Update Note'
            this.NoteId = this.parameters.c__nid;
            this.getNote(this.NoteId);
        }
        this.ParentId = this.parameters.c__vid;
    }

    renderedCallback() {
        if (this.hasRendered) return;
        this.hasRendered = true;
        // this.parameters = this.getQueryParameters();
        
        if (this.NoteId == 'CreateNode')
        {
            this.Action = 'Create Note';
            this.NoteId = null;
        }
        else
        {
            this.Action = 'Update Note'
            this.getNote(this.NoteId);
        }
    }

    getQueryParameters() {

        var params = {};
        var search = location.search.substring(1);

        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }
        console.log('Params:');
        console.log(params);

        return params;
    }

    getNote(RecordId){
        var params = { "recordId" : RecordId };
        getNoteInfo(params)
            .then(result => {
                console.log('Get result');
                console.log(result);
                this.Title = result.Title;
                this.Content = result.Body;
            }).catch(error => {
                console.log('Error: '+ error.body.message);
            });
    }

    saveNote()
    {
        console.log(this.NoteId);
        console.log(this.ParentId);
        console.log(this.Title);
        console.log(this.Content);
        var params = { "recordId" : this.NoteId,"parentIdIn" :  this.ParentId,
        "titleIn" : this.Title, 
        "bodyIn" : this.Content};
        saveNote(params)
            .then(result => {
                console.log('Get result');
                console.log(result);
              
                swal.fire({
					title: 'Save Note',
					text: "Note Saved",
					confirmButtonColor: '#3085d6',
					cancelButtonColor: '#d33',
					confirmButtonText: 'Confirm'
				}).then((result) => {
					if(result.value) {
					}
				});
            }).catch(error => {
                swal.fire({
                    title: 'Save Note',
                    text: error.body.message,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'Confirm'
                }).then((result) => {
                    if(result.value) {
                    }
                });
                console.log('Error: '+ error.body.message);
            });
    }


    onChangeTitile(event){
        this.Title = event.target.value;
        console.log(this.Title);
    }

    onChangeContent(event){
        this.Content = event.target.value;
        console.log(this.Content);
    }

}