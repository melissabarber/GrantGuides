/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 * 
 * GGW_ApplicationCtrlTest unt test for controller class support GGW.
 */
@IsTest
public class GGW_ApplicationCtrlTest {
    
    @TestSetup
    static void makeData(){
        // Create test sections
        GGW_Section__c stmt_need = new GGW_Section__c();
        stmt_need.Name = 'Statement of need';
        stmt_need.Sort_Order__c = 1;
        stmt_need.Suggested__c = true;
        stmt_need.Recommended__c = true;
        insert stmt_need;
        // create related Blocks
        GGW_Content_Block__c cblock = new GGW_Content_Block__c();
        cblock.Name = 'Project XYZ';
        cblock.Section__c = stmt_need.Id; // Link thsi block to Statement of need
        cblock.Description__c = 'The oceans are in more trouble than ever before. Right now it is estimated that up to 12 million metric tons of plastic—everything from plastic bottles and bags to microbeads—end up in the oceans each year. That’s a truckload of trash every minute.';
        cblock.Short_Description__c = 'Project XYZ';
        insert cblock;
        // -----------
        GGW_Section__c goal = new GGW_Section__c();
        goal.Name = 'Goals and objectives';
        goal.Sort_Order__c = 2;
        goal.Suggested__c = true;
        goal.Recommended__c = true;
        insert goal;
        // create related Blocks
        GGW_Content_Block__c bblock = new GGW_Content_Block__c();
        bblock.Name = 'New text';
        bblock.Section__c = goal.Id; // Link thsi block to Statement of need
        bblock.Description__c = 'Text placeholder try edit this text and save lets edit this text. Then add to library to reuse later on.';
        bblock.Short_Description__c = 'New block';
        insert bblock;
        // -----------
        // Create test sections
        GGW_Section__c program = new GGW_Section__c();
        program.Name = 'Program narrative';
        program.Sort_Order__c = 3;
        program.Suggested__c = true;
        program.Recommended__c = true;
        insert program;
        // create related Blocks
        GGW_Content_Block__c dblock = new GGW_Content_Block__c();
        dblock.Name = 'Green Pilot Program';
        dblock.Section__c = program.Id; // Link thsi block to Statement of need
        dblock.Description__c = 'The Environmental Green Pilot Program Proposal is an example of a proposal using Proposal Pack to pitch an environmental green pilot program to a community to reduce utility costs through renewable energy use.';
        dblock.Short_Description__c = 'Project XYZ';
        insert dblock;

        // Not selected section for search
        GGW_Section__c src = new GGW_Section__c();
        src.Name = 'Test search';
        src.Sort_Order__c = 2;
        src.Suggested__c = false;
        src.Recommended__c = false;
        insert src;
        // create related Blocks
        GGW_Content_Block__c sblock = new GGW_Content_Block__c();
        sblock.Name = 'Search block';
        sblock.Section__c = src.Id; // Link thsi block to Statement of need
        sblock.Description__c = 'Text placeholder try edit this text and save lets edit this text. Then add to library to reuse later on.';
        sblock.Short_Description__c = 'Search block';
        insert sblock;

    }

    @isTest
    static void testNewGrant(){
        // Query all suggested sections
        List<GGW_ApplicationCtrl.GGW_SectionWrapper> lst = GGW_ApplicationCtrl.getSections();
        List<String> sections = new List<String>();
        for (GGW_ApplicationCtrl.GGW_SectionWrapper gww : lst){
            if(gww.selected){
                sections.add(gww.recordid);
            }
        }

        Test.startTest();
        
        GGW_Grant_Application__c app = GGW_ApplicationCtrl.newGrant('MyTest Grant', sections);

        Test.stopTest();
        
        System.assertEquals('MyTest Grant', app.Name); 
        System.assertEquals('Progress', app.Status__c); 
        // Check if all section are created for app
        List<GGW_Selected_Item__c> selectedItems = [SELECT Id, Name, Grant_Application__c, GGW_Section__c, Sort_Order__c 
                                                    FROM GGW_Selected_Item__c WHERE Grant_Application__c =:app.Id];
        System.assertEquals(sections.size(), selectedItems.size()); 
    }
    @isTest
    static void testFindSections(){
        String searchKey = 'Test';
        Test.startTest();
        List<GGW_ApplicationCtrl.GGW_SectionWrapper> sw = GGW_ApplicationCtrl.findSections(searchKey);
        Test.stopTest();
        System.assertNotEquals(0, sw.size());
        System.assertEquals('Test search', sw[0].label);
        System.assertEquals(false, sw[0].selected);

        // Negative test asserts not found section by key
        searchKey = 'fail';
        List<GGW_ApplicationCtrl.GGW_SectionWrapper> swfail = GGW_ApplicationCtrl.findSections(searchKey);
        System.assertEquals(0, swfail.size());
    }
    @isTest
    static void testGetSections(){
        Test.startTest();
        List<GGW_ApplicationCtrl.GGW_SectionWrapper> sw = GGW_ApplicationCtrl.getSections();
        Test.stopTest();
        System.assertEquals(3, sw.size());
    }
    @isTest
    static void testContentBlocks(){
        List<GGW_Section__c> sectionList = [SELECT Id, Name FROM GGW_Section__c WHERE Name = 'Statement of need'];
        String sectionid = sectionList[0].Id;
        Test.startTest();
        List<GGW_ApplicationCtrl.GGW_ContentBlockWrapper> blockList = GGW_ApplicationCtrl.getContentBlocks(sectionId);
        Test.stopTest();
        // TODO add detailed assertions
        System.assertNotEquals(0, blockList.size());
    }
    @isTest
    static void testAddTextBlockToLibrary(){
        List<GGW_Section__c> sectionList = [SELECT Id, Name FROM GGW_Section__c WHERE Name = 'Statement of need'];
        String sectionid = sectionList[0].Id;
        String richtext = 'Adding new block text content to section to reuse. Example text';
        Test.startTest();
        String str = GGW_ApplicationCtrl.addTextBlockToLibrary(sectionid, richtext, 'Test block');
        Test.stopTest();
        // Check if new block was created with default name
        GGW_Content_Block__c block = [SELECT Id, Name, Section__c, Description__c FROM GGW_Content_Block__c WHERE Id =:str ];
        System.assertEquals('Test block', block.Name);
        System.assertEquals(str, block.Id);
        System.assertEquals(sectionList[0].Id, block.Section__c);
    }
    @isTest
    static void testCreateNewSection(){
        String name = 'Test section';
        Test.startTest();
        GGW_ApplicationCtrl.GGW_SectionWrapper sw = GGW_ApplicationCtrl.createNewSection(name);
        Test.stopTest();
        // assertion checks and set up
        GGW_Section__c maxOrder = [SELECT Sort_Order__c FROM GGW_Section__c WHERE Suggested__c = true  ORDER BY Sort_Order__c desc LIMIT 1];
        GGW_Section__c newSec = [SELECT Id, Name, Sort_Order__c, Recommended__c, Suggested__c FROM GGW_Section__c WHERE ID =: sw.recordid];
        System.assertEquals(name, sw.label);
        // Ensure the order was set correct for new section as last in list
        System.assertEquals(maxOrder.Sort_Order__c, newSec.Sort_Order__c);
        // Ensure defaults selected check
        System.assertEquals(newSec.Recommended__c,sw.selected);
        System.assertEquals(true, newSec.Recommended__c);
        System.assertEquals(true, newSec.Suggested__c);
    }

    @isTest
    static void testGetApplication(){
        // Query all suggested sections
        List<GGW_ApplicationCtrl.GGW_SectionWrapper> lst = GGW_ApplicationCtrl.getSections();
        List<String> sections = new List<String>();
        for (GGW_ApplicationCtrl.GGW_SectionWrapper gww : lst){
            if(gww.selected){
                sections.add(gww.recordid);
            }
        }
        GGW_Grant_Application__c app = GGW_ApplicationCtrl.newGrant('Grant App', sections);

        Test.startTest();
        GGW_ApplicationCtrl.GGW_GrantApplicationWrapper appWrapper = GGW_ApplicationCtrl.getApplication(app.Id);
        Test.stopTest();
        // assertion checks happy path and set up
        System.assertEquals(app.Id, appWrapper.recordid);
        System.assertEquals('Grant App',appWrapper.name);
        System.assertEquals('Progress', appWrapper.status);
        // Check selected Items created as content blocks wraper to number of sections
        System.assertEquals(sections.size(),appWrapper.selectedContentBlock.size());
    }
    @isTest
    static void testSaveSelectedSectionText(){
        // Query all suggested sections
        List<GGW_ApplicationCtrl.GGW_SectionWrapper> lst = GGW_ApplicationCtrl.getSections();
        List<String> sections = new List<String>();
        for (GGW_ApplicationCtrl.GGW_SectionWrapper gww : lst){
            if(gww.selected){
                sections.add(gww.recordid);
            }
        }
        GGW_Grant_Application__c app = GGW_ApplicationCtrl.newGrant('MyTest Grant Sections', sections);
        List<GGW_Selected_Item__c> selItemList = GGW_ApplicationCtrl.querySelectedItemsByGrant(app.Id);
        //List<GGW_Selected_Item__c> selItemList = [SELECT Id, Name, GGW_Section__c,Grant_Application__c, Sort_Order__c 
        //                                        FROM GGW_Selected_Item__c WHERE Grant_Application__c =:app.Id];
        String itemid = selItemList[0].Id; 
        String sectionId = selItemList[0].GGW_Section__c;
        Test.startTest();
        List<GGW_ApplicationCtrl.GGW_ContentBlockWrapper> bwList = GGW_ApplicationCtrl.getContentBlocks(sectionId);
        String blocktext = bwList[0].displaytext; // Save rich text from Block Wrappert to assert later
        GGW_ApplicationCtrl.saveSelectedSectionText(itemid, bwList[0].recordid);
        Test.stopTest();
        // assertion checks that item saved the Block text
        List<GGW_Selected_Item__c> savedItemList = GGW_ApplicationCtrl.querySelectedItemsByGrant(app.Id);
        System.assertEquals(blocktext, savedItemList[0].Text_Block__c); 
    }
    @isTest
    static void testReorderSections(){
        // Query all suggested sections
        List<GGW_ApplicationCtrl.GGW_SectionWrapper> lst = GGW_ApplicationCtrl.getSections();
        List<String> sections = new List<String>();
        for (GGW_ApplicationCtrl.GGW_SectionWrapper gww : lst){
            if(gww.selected){
                sections.add(gww.recordid);
            }
        }
        GGW_Grant_Application__c app = GGW_ApplicationCtrl.newGrant('Grant App Order', sections);
        List<GGW_Selected_Item__c> selItemList = GGW_ApplicationCtrl.querySelectedItemsByGrant(app.Id);
        // List of selected Iteam IDs - GGW_Selected_Item__c
        List<String> itemList =  new List<String>();
        // FLip order first/last
        String first = selItemList[0].Id;
        String last = selItemList[selItemList.size()-1].Id;
        for (GGW_Selected_Item__c item:selItemList){
            itemList.add(item.Id);
        }
        itemList[0] = last;
        itemList[selItemList.size()-1] = first;
        Test.startTest();
        GGW_ApplicationCtrl.reorderSections(itemList, app.Id);
        Test.stopTest();
        // Check fliped order
        List<GGW_Selected_Item__c> selOrderedList = GGW_ApplicationCtrl.querySelectedItemsByGrant(app.Id);
        System.assertEquals(last, selOrderedList[0].Id);                                             
        System.assertEquals(first, selOrderedList[selOrderedList.size()-1].Id);
    }
    @isTest
    static void testUpdateSelectedItemText(){
        // Query all suggested sections
        List<GGW_ApplicationCtrl.GGW_SectionWrapper> lst = GGW_ApplicationCtrl.getSections();
        List<String> sections = new List<String>();
        for (GGW_ApplicationCtrl.GGW_SectionWrapper gww : lst){
            if(gww.selected){
                sections.add(gww.recordid);
            }
        }
        GGW_Grant_Application__c app = GGW_ApplicationCtrl.newGrant('MyTest Grant', sections);
        List<GGW_Selected_Item__c> selItemList = [SELECT Id, Name, Text_Block__c, GGW_Section__c,Grant_Application__c, Sort_Order__c 
                                                FROM GGW_Selected_Item__c WHERE Grant_Application__c =:app.Id];
        String itemid = selItemList[0].Id; 
        String richtext = 'Update this text for section block.';
        Integer count = selItemList.size();
        Test.startTest();
        GGW_ApplicationCtrl.updateSelectedItemText(itemid, richtext);
        Test.stopTest();

        System.assertEquals(count, selItemList.size());
        // Check text was updated, query again to get updated record
        GGW_Selected_Item__c selItem = [SELECT Id, Name, Text_Block__c, GGW_Section__c, Grant_Application__c, Sort_Order__c 
                                                FROM GGW_Selected_Item__c WHERE Id =:itemid];
        System.assertEquals(richtext, selItem.Text_Block__c);
    }

    @isTest
    static void testDeleteSectionItem(){
        // Query all suggested sections
        List<GGW_ApplicationCtrl.GGW_SectionWrapper> lst = GGW_ApplicationCtrl.getSections();
        List<String> sections = new List<String>();
        for (GGW_ApplicationCtrl.GGW_SectionWrapper gww : lst){
            if(gww.selected){
                sections.add(gww.recordid);
            }
        }
        GGW_Grant_Application__c app = GGW_ApplicationCtrl.newGrant('Grant Delete section', sections);
        List<GGW_Selected_Item__c> selItemList = [SELECT Id, Name,GGW_Section__c,Grant_Application__c, Sort_Order__c 
                                                FROM GGW_Selected_Item__c WHERE Grant_Application__c =:app.Id];
        String itemid = selItemList[0].Id; 
        Integer sectionCount = selItemList.size();
        Test.startTest();
        GGW_ApplicationCtrl.deleteSection(itemId);
        Test.stopTest();

        List<GGW_Selected_Item__c> newItemList = [SELECT Id, Name,GGW_Section__c,Grant_Application__c, Sort_Order__c 
                                                FROM GGW_Selected_Item__c WHERE Grant_Application__c =:app.Id];

        // Check that item was deleted
        System.assertEquals(sectionCount-1, newItemList.size());
    }

}
