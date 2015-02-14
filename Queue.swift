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

class Element<T> : Equatable {
    
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

}

func ==<T>(lhs: Element<T>, rhs: Element<T>) -> Bool
{
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs);
}

postfix func ++<T>(inout e: Element<T>?) -> Element<T>?
{
    return e?.next;
}

postfix func --<T>(inout e: Element<T>?) -> Element<T>?
{
    return e?.prev;
}

class Queue<T>
{
    var head:Element<T>?;
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
    
    func each(callback:( index: Int, item:T?) -> Void)
    {
        var current = head, idx = 0;
        while ( current !== tail )
        {
            let item = current?.item;
            callback(index: idx, item: item);
            current++;
        }
    }
    
    func addAfter(element: Element<T>, after previous:  Element<T>)
    {
        var next = previous.next;
        
        element.prev = previous;
        previous.next = element;
        
        element.next = next;
        next?.prev = element;
    }
    
    func addBefore(element: Element<T>, before next:  Element<T>)
    {
        var previous = next.prev;
        
        element.next = next
        next.prev = element;
        
        element.prev = previous;
        previous?.next = element;
    }
    
}

class PQueue<T where T : Priority> : Queue<T>
{
    override func add(item:T)
    {
        if(head != tail)
        {
            self.priorityAdd(item);
        } else {
            super.add(item);
        }
    }
    
    private func priorityAdd(item: T)
    {
        let priority = item.priority;
        var element = Element(item: item, previous: nil);
        var current = head;
        while( (current != tail) && (priority <= current?.item?.priority)) {
            current++;
        }
        addBefore(element, before: current!);
    }
    
}