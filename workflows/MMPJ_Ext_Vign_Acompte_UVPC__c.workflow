<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>MMPJ_Ext_Vign_AcompteUVPC_Choix_Cognac</fullName>
        <ccEmails>partners-mmpj@pernod-ricard.com</ccEmails>
        <ccEmails>Pascal.Flouret@pernod-ricard.com</ccEmails>
        <description>MMPJ_Ext_Vign_AcompteUVPC_Choix_Cognac</description>
        <protected>false</protected>
        <senderAddress>partners-mmpj@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>MMPJ_Ext_Vign/MMPJ_Ext_Vign_AcompteUVPC_html</template>
    </alerts>
    <rules>
        <fullName>MMPJ_Ext_Vign_AcompteUVPC_Choix_Cognac</fullName>
        <actions>
            <name>MMPJ_Ext_Vign_AcompteUVPC_Choix_Cognac</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( 	NOT(ISPICKVAL(MMPJ_Ext_Vign_Choix__c ,&quot;&quot;)), 	ISPICKVAL(MMPJ_Ext_Vign_Contrat__r.MMPJ_Ext_Vign_Contrat_Segmentation__c,&quot;Cognac&quot;)   )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
