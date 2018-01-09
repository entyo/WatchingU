import { Component } from '@angular/core';
import { PersonStore } from '../shared/stores/person.store';

@Component({
  selector: 'app-item-card-list-set',
  templateUrl: './item-card-list-set.component.html',
  styleUrls: ['./item-card-list-set.component.sass']
})
export class ItemCardListSetComponent {

  constructor(public personStore: PersonStore) {}

}
