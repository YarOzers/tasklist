package com.example.tasklist.controller;


import com.example.tasklist.repository.PriorityRepository;
import com.example.tasklist.entity.Priority;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/priority")
public class PriorityController {

    private PriorityRepository priorityRepository;

    public PriorityController(PriorityRepository priorityRepository) {
        this.priorityRepository = priorityRepository;
    }

    @GetMapping("/test")
    public void test(){

        List<Priority> list = priorityRepository.findAll();
        System.out.println("list = " + list );

    }
}
