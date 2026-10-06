/**
 * @file ring_buffer.c
 * @author your name (you@domain.com)
 * @brief 
 * @version 0.1
 * @date 2026-09-20
 * 
 * @copyright Copyright (c) 2026
 * 
 */
#include "ring_buffer.h"
#include <stdbool.h>
#include <stdint.h>

bool ring_buffer_push(ring_buffer_t *rb, uint8_t data)
{
    uint8_t next_head = (rb->head + 1) & RING_BUFFER_MASK;
    if (next_head == rb->tail)
    {
        return false;
    }
    rb->buffer[rb->head] = data;
    rb->head = next_head;

    return true;
}

bool ring_buffer_pop(ring_buffer_t *rb, uint8_t *byte)
{
    if(rb->tail == rb->head)
        return false; // Buffer is empty.
    
    // STEP 1: Write buffer into *byte
    *byte =  rb->buffer[rb->tail];

    // STEP 2: Update ring buffer tail
    rb->tail = (rb->tail + 1) & RING_BUFFER_MASK;

    return true;
}
