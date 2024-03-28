package com.example.tasklist.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.Date;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@EqualsAndHashCode
public class Task {

    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Id
    @Column(name = "id", nullable = false)
    Integer id;

    @Basic
    @Column(name = "title", nullable = false, length = 100)
    String title;

    @Basic
    @Column(name = "completed", nullable = true)
    Integer completed;

    @Basic
    @Column(name = "date", nullable = true)
    Date date;

    @ManyToOne
    @JoinColumn(name = "priority_id", referencedColumnName = "id")
    Priority priority;

    @ManyToOne
    @JoinColumn(name = "category_id", referencedColumnName = "id")
    Category category;


}
