package com.example.app.helper

import androidx.lifecycle.Observer

open class Event<out T>(private val content: T) {

    private var consumed = false

    /**
     * Consumes the content if it's not been consumed yet.
     * @return The unconsumed content or `null` if it was consumed already.
     */
    fun consume(): T? {
        return if (consumed) {
            null
        } else {
            consumed = true
            content
        }
    }
}

class EventObserver<T>(private val eventContentChanged: (T) -> Unit) : Observer<Event<T>> {
    override fun onChanged(event: Event<T>?) {
        event?.consume()?.run(eventContentChanged)
    }
}