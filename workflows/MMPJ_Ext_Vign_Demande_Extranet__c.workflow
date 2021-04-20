<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>MMPJ_Ext_Vign_DemandeExtranet_Alerte_Champagne</fullName>
        <description>MMPJ_Ext_Vign_DemandeExtranet_Alerte_Champagne</description>
        <protected>false</protected>
        <recipients>
            <recipient>MMPJ_Ext_Vign_Admins_Fonctionnels_Champ</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MMPJ_Ext_Vign/MMPJ_Ext_Vign_Nouvelle_Demande</template>
    </alerts>
    <alerts>
        <fullName>MMPJ_Ext_Vign_DemandeExtranet_Alerte_Cognac</fullName>
        <description>MMPJ_Ext_Vign_DemandeExtranet_Alerte_Cognac</description>
        <protected>false</protected>
        <recipients>
            <recipient>MMPJ_Ext_Vign_Admins_Fonctionnels_Cognac</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MMPJ_Ext_Vign/MMPJ_Ext_Vign_Nouvelle_Demande</template>
    </alerts>
    <rules>
        <fullName>MMPJ_Ext_Vign_DemandeExtranet_Alerte_Champagne</fullName>
        <actions>
            <name>MMPJ_Ext_Vign_DemandeExtranet_Alerte_Champagne</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Envoi d&apos;une alerte email à l&apos;administrateur Champagne à la création d&apos;une demande extranet vigneron</description>
        <formula>ISPICKVAL(MMPJ_Ext_Vign_Contact__r.MMPJ_Ext_Vign_Contact_Segmentation__c,&quot;Champagne&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MMPJ_Ext_Vign_DemandeExtranet_Alerte_Cognac</fullName>
        <actions>
            <name>MMPJ_Ext_Vign_DemandeExtranet_Alerte_Cognac</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Envoi d&apos;une alerte email à l&apos;administrateur Cognac à la création d&apos;une demande extranet vigneron</description>
        <formula>ISPICKVAL(MMPJ_Ext_Vign_Contact__r.MMPJ_Ext_Vign_Contact_Segmentation__c,&quot;Cognac&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
