package com.example.fiscotest.controller;

import com.example.fiscotest.HelloWorld;
import org.fisco.bcos.sdk.BcosSDK;
import org.fisco.bcos.sdk.client.Client;
import org.fisco.bcos.sdk.crypto.keypair.CryptoKeyPair;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class FiscoController {
    public final String configFile = FiscoController.class.getClassLoader().getResource("fisco-config.toml").getPath();
    BcosSDK sdk =  BcosSDK.build(configFile);
    Client client = sdk.getClient(Integer.valueOf(1));

    HelloWorld helloWorld=null;
    @GetMapping("/deploy")
    public String deploycontract() throws Exception{
        CryptoKeyPair cryptoKeyPair = client.getCryptoSuite().getCryptoKeyPair();
        helloWorld = HelloWorld.deploy(client,cryptoKeyPair);
        return "deploy success!!";
    }

    @GetMapping("/get")
    public String getcontract() throws Exception{
        String value = helloWorld.get();
        return "ContractValue="+value;
    }

    @PostMapping("/set")
    public String setcontract(String name) throws Exception{
        helloWorld.set(name);
        String value = helloWorld.get();
        return "set success!! now ContractValue="+value;
    }
}
