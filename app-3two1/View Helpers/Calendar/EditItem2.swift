//
//  EditItem2.swift
//  app-3two1
//
//  Created by Anubhav Punetha on 29.01.24.
//

import SwiftUI

struct EditItem2: View {
    
    @Binding var givenItem: Task?
    
    var body: some View {
        Text(givenItem!.name!)
    }
}

//#Preview {
//    EditItem2()
//}
