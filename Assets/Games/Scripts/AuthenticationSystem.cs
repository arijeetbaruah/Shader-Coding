using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.Services.Core;
using Unity.Services.Authentication;
using System.Threading.Tasks;
using Newtonsoft.Json;

public class AuthenticationSystem : MonoBehaviour
{
    private IEnumerator Start()
    {
        InitializationOptions options = new InitializationOptions();
        options.SetProfile("test_profile");
        yield return UnityServices.InitializeAsync(options);
        Debug.Log($"UnityService {UnityServices.State}");
        SetupEvents();
        yield return SignInCachedUser();
    }

    private void OnDestroy()
    {
        RemoveEvents();
    }

    private IEnumerator SignInCachedUser()
    {
        if (!AuthenticationService.Instance.SessionTokenExists)
        {
            Debug.Log("No local User Found");
            yield break;
        }

        yield return SignInAnonymoslyAsync();
    }

    public void OnSignInAnonymoslyClick()
    {
        StartCoroutine(SignInAnonymosly());
    }

    private IEnumerator SignInAnonymosly()
    {
        yield return SignInAnonymoslyAsync();
    }

    public async Task SignInAnonymoslyAsync()
    {
        try
        {
            await AuthenticationService.Instance.SignInAnonymouslyAsync();
            Debug.Log("Sign in anonymously succeeded!");
            Debug.Log($"PlayerID: {AuthenticationService.Instance.PlayerId}");
        }
        catch (AuthenticationException ex)
        {
            Debug.LogException(ex);
        }
        catch (RequestFailedException ex)
        {
            Debug.LogException(ex);
        }

        var playerInfoTask = AuthenticationService.Instance.GetPlayerInfoAsync();
        await playerInfoTask;

        Debug.Log(JsonConvert.SerializeObject(playerInfoTask.Result));
    }

    public void SetupEvents()
    {
        AuthenticationService.Instance.SignedIn += OnSignedIn;
        AuthenticationService.Instance.SignInFailed += OnSignInFailed;
        AuthenticationService.Instance.SignedOut += OnSignedOut;
        AuthenticationService.Instance.Expired += OnExpired;
    }

    public void RemoveEvents()
    {
        AuthenticationService.Instance.SignedIn -= OnSignedIn;
        AuthenticationService.Instance.SignInFailed -= OnSignInFailed;
        AuthenticationService.Instance.SignedOut -= OnSignedOut;
        AuthenticationService.Instance.Expired -= OnExpired;
    }

    private void OnSignedIn()
    {
        Debug.Log($"PlayerID: {AuthenticationService.Instance.PlayerId}");
        Debug.Log($"Access Token: {AuthenticationService.Instance.AccessToken}");
    }

    private void OnSignInFailed(RequestFailedException err)
    {
        Debug.LogError(err);
    }

    private void OnSignedOut()
    {
        Debug.Log("Player signed out.");
    }

    private void OnExpired()
    {
        Debug.Log("Player session could not be refreshed and expired.");
    }
}
