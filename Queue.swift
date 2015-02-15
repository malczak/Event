//
//  Queue.swift
//  MhPicImport
//
//  Created by malczak on 14/02/15.
//  Copyright (c) 2015 thepiratecat. All rights reserved.
//

import Foundation

protocol Priority
{
    var priority:Int { get set }
}

class Element<T>
{
    var item:T?;
    
    weak var prev:Element<T>?;
    
    var next:Element<T>?;
    
    init(item: T?, previous: Element<T>?)
    {
        self.item = item;
        self.prev = previous;
        self.next = nil;
        if(self.prev != nil)
        {
            self.prev?.next = self;
        }
    }

    deinit {
        item = nil;
        prev = nil;
        next = nil;
    }
}

func ==<T:AnyObject>(element:Element<T>?, value:T) -> Bool
{
    if let _element = element {
        if let _elementValue = _element.item {
            return value === _elementValue;
        }
    }
    return false;
}

postfix func ++<T>(inout e: Element<T>?) -> Element<T>?
{
    let old = e;
    e = e?.next;
    return old;
}

postfix func --<T>(inout e: Element<T>?) -> Element<T>?
{
    let old = e;
    e = e?.prev;
    return old;
}

class Queue<T: AnyObject>
{
    var head:Element<T>?
    var tail:Element<T>?
    
    init()
    {
        head = Element<T>(item: nil, previous: nil);
        tail = head;
    }
    
    func first() -> T?
    {
        return head?.item;
    }
    
    func last() -> T?
    {
        return tail?.prev?.item
    }
    
    func add(item:T)
    {
        tail?.item = item;
        tail = Element<T>(item: nil, previous: tail);
    }
    
    func remove(item:T)
    {
        weak var current = head;
        while( !(current === tail) && !(current == item) )
        {
            current++;
        }
        
        if(current != nil)
        {
            remove(current!);
        }
    }
    
    func remove(index: Int)
    {
        weak var current = head;
        var idx = index;
        
        while ( !(current === tail) && (idx > 0) ){
            idx -= 1;
            current++;
        }
        
        if(current != nil)
        {
            remove(current!);
        }
    }
    
    func remove(element: Element<T>) -> Element<T>?
    {
        if(head === tail)
        {
            return nil;
        }
        
        let fixHead = element === head;
        var previous = element.prev;
        var next = element.next;
        
        previous?.next = next;
        next?.prev = previous;
        
        element.next = nil;
        element.prev = nil;
        element.item = nil;
        
        if(fixHead)
        {
            head = next;
        }
        
        return previous;
    }

    func each(callback:(Int,T?) -> Void)
    {
        weak var current = head;
        var idx = 0;
        while ( !(current === tail) )
        {
            weak var next = current?.next;
            let item:T? = current?.item;
            callback(idx++,item);
            current = next;
        }
    }
    
    func addAfter(element: Element<T>, after previous:  Element<T>) -> Element<T>
    {
        var next = previous.next;
        
        element.prev = previous;
        previous.next = element;
        
        element.next = next;
        next?.prev = element;
        
        return previous;
    }
    
    func addBefore(element: Element<T>, before next:  Element<T>) -> Element<T>
    {
        var previous = next.prev;
        
        element.next = next
        next.prev = element;
        
        element.prev = previous;
        previous?.next = element;
        
        return element;
    }

    func clear()
    {
        var current = head;
        while( !(current === tail) ){
            var prev = current++;
            prev?.next = nil;
            prev?.item = nil;
        }
    }
    
    deinit {
        clear();
    }
}

class DefaultItem: Priority
{
    unowned var data:AnyObject;
    
    var priority:Int;
    
    init(data: AnyObject, priority: Int)
    {
        self.data = data;
        self.priority = priority;
    }
    
    deinit
    {
    }
    
}

class PQueue<T where T: AnyObject, T:Priority> : Queue<T>
{
    var maximum:Int? {
        get {
            return first()?.priority;
        }
    }
    
    var minimum:Int? {
        get {
            return last()?.priority;
        }
    }
    
    override func add(item:T)
    {
        (head === tail) ? super.add(item) : self.priorityAdd(item);
    }
    
    private func priorityAdd(item: T)
    {
        var element = Element(item: item, previous: nil);
        let priority = item.priority;
        if(priority > maximum) {
            head = addBefore(element, before: head!)
        } else
        if(priority <= minimum) {
            addBefore(element, before: tail!)
        } else {
            var current = head;
            while(priority <= current?.item?.priority)
            {
                current++;
            }
            addBefore(element, before: current!);
        }
    }
    
}