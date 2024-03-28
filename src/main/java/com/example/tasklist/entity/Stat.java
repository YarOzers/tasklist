package com.example.tasklist.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.util.Objects;

@Entity
@Data
@EqualsAndHashCode
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Stat {

    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Id
    @Column(name = "id", nullable = false)
    Integer id;

    @Basic
    @Column(name = "completed_total", nullable = true)
    Long completedTotal;

    @Basic
    @Column(name = "uncompleted_total", nullable = true)
    Long uncompletedTotal;


}
