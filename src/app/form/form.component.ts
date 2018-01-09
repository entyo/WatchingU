import { Component } from '@angular/core';

import { ItemStore } from "../shared/stores/item.store";
import { PersonStore } from "../shared/stores/person.store";
import { Item } from "../../models/item";
import { Person } from '../../models/person';

@Component({
  selector: 'app-form',
  templateUrl: './form.component.html',
  styleUrls: ['./form.component.sass']
})
export class FormComponent {

  username: string;

  constructor(
    public itemStore: ItemStore,
    public personStore: PersonStore
  ) { }

  onClick () {
    console.log(this.username);
    if (!this.username) {
      return;
    }
    // Trim '@'
    if (this.username.charAt(0) === '@') {
      this.username = this.username.slice(1, this.username.length);
    }

    // Personの追加(すでに存在したら何もしない)
    this.personStore.list.toPromise()
    .then(storePersons => {
      const isAlreadyExists = storePersons
        .map(person => person.name)
        .some(name => name === this.username);
      if (isAlreadyExists) {
        return;
      }
      const newPerson = new Person(this.username);
      this.personStore.insert(newPerson);
    })
    .catch(e =>  {
      console.error(e);
      return;
    })
  }
}
