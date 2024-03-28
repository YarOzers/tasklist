package com.example.tasklist.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.Collection;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@EqualsAndHashCode
public class Category {

    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Id
    @Column(name = "id", nullable = false)
    Integer id;

    @Basic
    @Column(name = "title", nullable = false, length = 45)
    String title;

    @Basic
    @Column(name = "completed_count", nullable = true)
    Long completedCount;

    @Basic
    @Column(name = "uncompleted_count", nullable = true)
    Long uncompletedCount;

    @OneToMany(mappedBy = "category")
    Collection<Task> tasksById;

}
