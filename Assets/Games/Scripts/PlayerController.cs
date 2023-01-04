using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    [SerializeField]
    private NavMeshAgent agent;
    [SerializeField]
    private float movementSpeed = 10f;

    public Vector2 playerMovementInput;

    private void Update()
    {
        Vector3 movement = new Vector3(playerMovementInput.x, 0, playerMovementInput.y);
        agent.Move(movement.normalized * Time.deltaTime * movementSpeed);
    }

    public void OnMove(InputValue inputValue)
    {
        playerMovementInput = inputValue.Get<Vector2>();
    }
}
