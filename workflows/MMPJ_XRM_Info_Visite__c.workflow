<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>MMPJ_XRM_Envoi_email_rappel_visite_planifie</fullName>
        <description>MMPJ_XRM_Envoi email rappel visite planifiée</description>
        <protected>false</protected>
        <recipients>
            <field>MMPJ_XRM_Utilisateur_A_Notifier__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MMPJ_XRM_templates/MMPJ_XRM_Email_rappel_visite</template>
    </alerts>
    <rules>
        <fullName>MMPJ_XRM_email_rappel_visite</fullName>
        <actions>
            <name>MMPJ_XRM_Envoi_email_rappel_visite_planifie</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>MMPJ_XRM_Info_Visite__c.MMPJ_XRM_date_Heure_Rappel__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>MMPJ_XRM_Info_Visite__c.MMPJ_XRM_date_Heure_Rappel__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
