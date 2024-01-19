package com.example.fiscotest.controller;

import com.example.fiscotest.AssetLeasingTable;
import org.fisco.bcos.sdk.BcosSDK;
import org.fisco.bcos.sdk.client.Client;
import org.fisco.bcos.sdk.contract.precompiled.consensus.ConsensusService;
import org.fisco.bcos.sdk.crypto.CryptoSuite;
import org.fisco.bcos.sdk.crypto.keypair.CryptoKeyPair;
import org.fisco.bcos.sdk.transaction.codec.decode.TransactionDecoderInterface;
import org.fisco.bcos.sdk.transaction.codec.decode.TransactionDecoderService;
import org.fisco.bcos.sdk.transaction.model.dto.TransactionResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigInteger;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.TimeZone;

@RestController
public class AssetController {
    public final String configFile = FiscoController.class.getClassLoader().getResource("fisco-config.toml").getPath();
    BcosSDK sdk =  BcosSDK.build(configFile);
    Client client = sdk.getClient(Integer.valueOf(1));
    CryptoSuite cryptoSuite = client.getCryptoSuite();
    TransactionDecoderInterface decoder = new TransactionDecoderService(cryptoSuite);
    CryptoKeyPair cryptoKeyPair = client.getCryptoSuite().getCryptoKeyPair();
    //AssetLeasingTable assetleasing= null;
    AssetLeasingTable assetleasing = AssetLeasingTable.load("0x0e9677d407e852046499b6110b799d1446da1ae7", client,cryptoKeyPair);

    ConsensusService consensusService = new ConsensusService(client, cryptoKeyPair);

    @PostMapping("/DeleteNode")
    public String deletenodes(String nodeid) throws Exception{
        consensusService.removeNode(nodeid);
        return "delete node:" + nodeid + " success!!";
    }


    @PostMapping("/AddNewNode")
    public String addnodes(String nodeid) throws Exception{
        consensusService.addObserver(nodeid);
        consensusService.addSealer(nodeid);
        return "add node:" + nodeid + " success!!";
    }

    @GetMapping("/AssetDeploy")
    public String deploycontract() throws Exception{
        assetleasing = AssetLeasingTable.deploy(client,cryptoKeyPair);
        return "deploy success!!";
    }

    @PostMapping("/RegisterAsset")
    public String registerAsset(String owner, String assetname, Integer priceperhour) throws Exception{
        TransactionResponse transactionResponse = decoder.decodeReceiptStatus(assetleasing.registerAsset(owner, assetname, BigInteger.valueOf(priceperhour)));
        return transactionResponse.toString();
    }

    @GetMapping("/GetAvailableAssets")
    public String getAvailableAssets() throws Exception{
        List assetownerlist = assetleasing.getAvailableAssets_owner();
        List<String> result_owner = new ArrayList<>();
        for(int i=0;i<assetownerlist.size();i++){
            byte[] bytes = (byte[]) assetownerlist.get(i);
            int bytecont = 0;
            for(int j=0;j<bytes.length;j++){
                if(bytes[j]!=0){
                    bytecont++;
                }
            }
            byte[] newbytes = new byte[bytecont];
            for(int k=0;k<bytecont;k++){
                newbytes[k] = bytes[k];
            }
            String str = new String(newbytes, StandardCharsets.UTF_8);
            result_owner.add(str);
        }
        List assetlist = assetleasing.getAvailableAssets_assetID();
        List<String> result_assetID = new ArrayList<>();
        for(int i=0;i<assetlist.size();i++){
            byte[] bytes = (byte[]) assetlist.get(i);
            int bytecont = 0;
            for(int j=0;j<bytes.length;j++){
                if(bytes[j]!=0){
                    bytecont++;
                }
            }
            byte[] newbytes = new byte[bytecont];
            for(int k=0;k<bytecont;k++){
                newbytes[k] = bytes[k];
            }
            String str = new String(newbytes, StandardCharsets.UTF_8);
            result_assetID.add(str);
        }

        List assetpricelist = assetleasing.getAvailableAssets_pricePerHour();

        System.out.println(result_owner);
        System.out.println(result_assetID);
        System.out.println(assetpricelist);
        return "get available assets success!!";
    }

    @GetMapping("/GetLeasedAssets")
    public String getLeasedAssets() throws Exception{
        List assetownerlist = assetleasing.getLeasedAssets_owner();
        List<String> result_owner = new ArrayList<>();
        for(int i=0;i<assetownerlist.size();i++){
            byte[] bytes = (byte[]) assetownerlist.get(i);
            int bytecont = 0;
            for(int j=0;j<bytes.length;j++){
                if(bytes[j]!=0){
                    bytecont++;
                }
            }
            byte[] newbytes = new byte[bytecont];
            for(int k=0;k<bytecont;k++){
                newbytes[k] = bytes[k];
            }
            String str = new String(newbytes, StandardCharsets.UTF_8);
            result_owner.add(str);
        }

        List assetlist = assetleasing.getLeasedAssets_assetID();
        List<String> result = new ArrayList<>();
        for(int i=0;i<assetlist.size();i++){
            byte[] bytes = (byte[]) assetlist.get(i);
            int bytecont = 0;
            for(int j=0;j<bytes.length;j++){
                if(bytes[j]!=0){
                    bytecont++;
                }
            }
            byte[] newbytes = new byte[bytecont];
            for(int k=0;k<bytecont;k++){
                newbytes[k] = bytes[k];
            }
            String str = new String(newbytes, StandardCharsets.UTF_8);
            result.add(str);
        }

        List assetpricelist = assetleasing.getLeasedAssets_pricePerHour();

        List assetrenterlist = assetleasing.getLeasedAssets_renter();
        List<String> result_renter = new ArrayList<>();
        for(int i=0;i<assetrenterlist.size();i++){
            byte[] bytes = (byte[]) assetrenterlist.get(i);
            int bytecont = 0;
            for(int j=0;j<bytes.length;j++){
                if(bytes[j]!=0){
                    bytecont++;
                }
            }
            byte[] newbytes = new byte[bytecont];
            for(int k=0;k<bytecont;k++){
                newbytes[k] = bytes[k];
            }
            String str = new String(newbytes, StandardCharsets.UTF_8);
            result_renter.add(str);
        }

        List assetrentedtimelist = assetleasing.getLeasedAssets_rentedTime();

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss z");
        sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
        List timelist = new ArrayList();
        for(int i=0;i<assetrentedtimelist.size();i++){
            LocalDateTime dateTime = LocalDateTime.ofInstant(Instant.ofEpochSecond(((BigInteger)assetrentedtimelist.get(i)).longValue()/1000), ZoneId.of("Asia/Shanghai"));
            timelist.add(dateTime);
        }


        System.out.println(result_owner);
        System.out.println(result);
        System.out.println(assetpricelist);
        System.out.println(result_renter);
        System.out.println(timelist);
        return "get leased assets success!!";
    }

    @PostMapping("/LeaseAsset")
    public String leaseAsset(String renter,String assetname) throws Exception{
        TransactionResponse transactionResponse = decoder.decodeReceiptStatus(assetleasing.leaseAsset(renter, assetname));
        return transactionResponse.toString();
    }

    @PostMapping("/ReturnAsset")
    public String returnAsset(String renter, String assetname) throws Exception{
        TransactionResponse transactionResponse = decoder.decodeReceiptStatus(assetleasing.returnAsset(renter, assetname));
        return transactionResponse.toString();
    }

    @GetMapping("/GetUserDebts")
    public String getuserdebts(String debtor) throws Exception{
        List assetID_list = assetleasing.getDebt_assetID(debtor);
        List<String> result = new ArrayList<>();
        for(int j=0;j<assetID_list.size();j++){
            byte[] bytes = (byte[]) assetID_list.get(j);
            int bytecont = 0;
            for(int k=0;k<bytes.length;k++){
                if(bytes[k]!=0){
                    bytecont++;
                }
            }
            byte[] newbytes = new byte[bytecont];
            for(int k=0;k<bytecont;k++){
                newbytes[k] = bytes[k];
            }
            String str = new String(newbytes, StandardCharsets.UTF_8);
            result.add(str);
        }

        List pricePerHour_list = assetleasing.getDebt_pricePerHour(debtor);
        List leaseHours_list = assetleasing.getDebt_leaseHours(debtor);
        List amount_list = assetleasing.getDebt_amount(debtor);
        List creditor_list = assetleasing.getDebt_creditor(debtor);
        List<String> result_creditor = new ArrayList<>();
        for(int j=0;j<creditor_list.size();j++){
            byte[] bytes = (byte[]) creditor_list.get(j);
            int bytecont = 0;
            for(int k=0;k<bytes.length;k++){
                if(bytes[k]!=0){
                    bytecont++;
                }
            }
            byte[] newbytes = new byte[bytecont];
            for(int k=0;k<bytecont;k++){
                newbytes[k] = bytes[k];
            }
            String str = new String(newbytes, StandardCharsets.UTF_8);
            result_creditor.add(str);
        }
        System.out.println("debts_assetID_list: " + result);
        System.out.println("debts_pricePerHour_list: " + pricePerHour_list);
        System.out.println("debts_leaseHours_list: " + leaseHours_list);
        System.out.println("debts_amount_list: " + amount_list);
        System.out.println("debts_creditor_list: " + result_creditor);
        return "get user debts success!!";
    }

}
